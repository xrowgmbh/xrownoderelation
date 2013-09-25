<?php

/*
    this script builds ezobjectrelation attributes to xrownoderelation attributes
    php -d memory_limit=2048M bin/php/ezexec.php extension/xrownoderelation/bin/rebuild_from_objectrelation.php
*/

$cli = eZCLI::instance();
$rebuild_list = array();
// $rebuild_list = array( classID, oldIdentifier(MUST BE TYPE ezobjectrelation), newIdentifier(will be created automatically), newAttributeName, deleteOldAttribute(true or false - this automatically renames the attribute to the old identifier) )
$rebuild_list[] = array( 61, "alternative_link", "alternative_link1", "Alternativer Link NEU", false);

$cli->output( "Starting the script" );
$installer = new eZSiteInstaller( );
$db = eZDB::instance();
$converted_count = 0;

foreach ( $rebuild_list as $rebuilding )
{
    $classID = $rebuilding[0];
    $class = eZContentClass::fetch( $classID );

    if ( $class instanceof eZContentClass )
    {
        $cli->output( "Analyzing Class: " . $class->attribute("name") );
        $oldIdentifier = $rebuilding[1];
        $oldAttribute = $class->fetchAttributeByIdentifier( $oldIdentifier );
        if ( $oldAttribute instanceof eZContentClassAttribute )
        {
            $newIdentifier = $rebuilding[2];
            $cli->output( "Creating new identifier: " . $newIdentifier );
            
            if ( $class->fetchAttributeByIdentifier( $newIdentifier ) instanceof eZContentClassAttribute )
            {
                $cli->output( "Skipping attribute to prevent damage. New Identifier already exists!" );
            }
            else
            {
                $installer->addClassAttributes( array( 'class' => array( 'id' => $classID ),
                                                       'attributes' => array( array( 'identifier' => $newIdentifier, 
                                                                                     'name' => $rebuilding[3], 
                                                                                     'data_type_string' => 'xrownoderelation' )
                                                    ) ) );
                $newAttribute = $class->fetchAttributeByIdentifier( $newIdentifier );
                
                $cli->output( "Identifier created successful." );
                if ( $newAttribute instanceof eZContentClassAttribute ) {
                
                    $cli->output( "Converting data from " . $oldIdentifier . " to " . $newIdentifier );
                    
                    $sourceID = 1;
                    $limit_per_fetch = 100;
                    
                    $params = array();
                    $params['Offset'] = 0;
                    $params['Depth'] = 9999; 
                    $params['ClassFilterType'] = 'include';
                    $params['ClassFilterArray'] = array ( $class->attribute("identifier") );
                    $params['IgnoreVisibility'] = true;
                    $params['Limitation'] = array();
                    $total_count = eZContentObjectTreeNode::subTreeCountByNodeID( $params, $sourceID );
                    $params['Limit'] = $limit_per_fetch;
                    
                    $cli->output( "Checking " . $total_count . " Elements" );
                    
                    do {
                        $nodeArray = eZContentObjectTreeNode::subTreeByNodeID( $params, $sourceID );
                        $params['Offset'] = $params['Offset'] + $limit_per_fetch;

                        $count = count($nodeArray);
                        $cli->output( "############# Checking the next " . $limit_per_fetch . " Elements(" . $params['Offset'] . ") ##############" );
                        
                        foreach ( $nodeArray as $result )
                        {
                            echo ".";
                            //fetching the data map
                            $dm = $result->dataMap();
                            $our_dm = $dm[$oldIdentifier];
                            if ( $dm[$oldIdentifier] instanceof eZContentObjectAttribute && $our_dm->hasContent() )
                            {
                                //reading old data_int
                                $old_connection = $our_dm->DataInt;
                                if ( $dm[$newIdentifier] instanceof eZContentObjectAttribute )
                                {
                                    //getting the main node of the old object connection
                                    $connected_object = eZContentObject::fetch($old_connection);
                                    $main_node_of_connected_object = $connected_object->mainNodeID();
                                    //setting data_int to new attribute
                                    $db->begin();
                                    $dm[$newIdentifier]->setAttribute("data_int", $main_node_of_connected_object);
                                    $dm[$newIdentifier]->setAttribute("sort_key_int", $main_node_of_connected_object);
                                    $dm[$newIdentifier]->store();
                                    $result->store();
                                    $db->commit();
                                    
                                    echo "+";
                                    //could be improved form output
                                    //$cli->output( $node_id );
                                    
                                    $converted_count = $converted_count+1;
                                }
                            }
                            
                        }
                        eZContentObject::clearCache();
                    } while ($count == $limit_per_fetch);
                    
                    $removal = $rebuilding[4];
                    if( $removal )
                    {
                        $oldAttribute->removeThis;
                        //currently not supported. Identifier Change must be done manually
                        //$newAttribute->setIdentifier( $oldIdentifier ) ???;
                    }
                }
                $cli->output( $converted_count . " Nodes converted." );
            }
        }
        else
        {
            $cli->output( "Could not find identifier: " . $oldIdentifier );
        }
    }
    else
    {
        $cli->output( "Class not found with ID: " . $classID );
    }
}

?>