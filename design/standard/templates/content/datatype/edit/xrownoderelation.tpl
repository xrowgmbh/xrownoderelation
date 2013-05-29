{default attribute_base=ContentObjectAttribute}
{let class_content=$attribute.contentclass_attribute.content}
{switch match=$class_content.selection_type}
{* Browse. *}
{case match=0}
{def $my_node=fetch( 'content', 'node', hash( 'node_id', $attribute.data_int) )}
<div class="block" id="ezobjectrelation_browse_{$attribute.id}">

<table class="list{if $my_node|is_null()} hide{/if}" cellspacing="0">
<thead>
<tr>
    <th>{'Name'|i18n( 'design/standard/content/datatype' )}</th>
    <th>{'Type'|i18n( 'design/standard/content/datatype' )}</th>
    <th>{'Section'|i18n( 'design/standard/content/datatype' )}</th>
    <th>{'Published'|i18n( 'design/standard/content/datatype' )}</th>
</tr>
</thead>
<tbody>
<tr class="bglight">
{if $my_node.hidden_status_string|contains('Sichtbar')}
    {* Name *}
    <td>{$my_node.name|wash()}</td>

    {* Type *}
    <td>{$my_node.class_name|wash()}</td>

    {* Section *}
    <td>{fetch( section, object, hash( section_id, $my_node.object.section_id ) ).name|wash}</td>

    {* Published. *}
    <td>{if $my_node.object.status|ne( 1 )}
            {'No'|i18n( 'design/standard/content/datatype' )}
        {else}
            {'Yes'|i18n( 'design/standard/content/datatype' )}
        {/if}
    </td>
{else}
    <td>--name--</td>
    <td>--class-name--</td>
    <td>--section-name--</td>
    <td>--published--</td>
{/if}
</tr>
</tbody>
</table>

{if $my_node|is_null()}
    <p class="ezobject-relation-no-relation">{'There are no related object.'|i18n( 'design/standard/content/datatype' )}</p>
{/if}

<div class="block inline-block">
{if $attribute.class_content.default_selection_node}
    <input type="hidden" name="{$attribute_base}_browse_for_object_start_node[{$attribute.id}]" value="{$attribute.class_content.default_selection_node|wash}" />
{/if}
{if $my_node|is_null()|not}
    <input class="button ezobject-relation-remove-button" type="submit" name="CustomActionButton[{$attribute.id}_remove_object]" value="{'Remove node'|i18n( 'extension/xrownoderelation/datatypes' )}" />
{else}
    <input class="button-disabled ezobject-relation-remove-button" type="submit" name="CustomActionButton[{$attribute.id}_remove_object]" value="{'Remove node'|i18n( 'extension/xrownoderelation/datatypes' )}" disabled="disabled" />
{/if}
</div>

<h4>{'Add an Node in the relation'|i18n( 'extension/xrownoderelation/datatypes' )}</h4>
<div class="left">
<input type="hidden" name="{$attribute_base}_data_object_relation_id_{$attribute.id}" value="{$attribute.data_int}" />
{if $my_node.hidden_status_string|contains('Sichtbar')}
    <input class="button-disabled ezobject-relation-add-button" type="submit" name="CustomActionButton[{$attribute.id}_browse_object]" value="{'Add an existing node'|i18n( 'extension/xrownoderelation/datatypes' )}" title="{'Browse to add an existing object in this relation'|i18n( 'design/standard/content/datatype' )}" disabled="disabled" />
    {*include uri='design:content/datatype/edit/ezobjectrelation_ajaxuploader.tpl' enabled=false()*}
{else}
    <input class="button ezobject-relation-add-button" type="submit" name="CustomActionButton[{$attribute.id}_browse_object]" value="{'Add an existing node'|i18n( 'extension/xrownoderelation/datatypes' )}" title="{'Browse to add an existing object in this relation'|i18n( 'design/standard/content/datatype' )}" />
    {*include uri='design:content/datatype/edit/ezobjectrelation_ajaxuploader.tpl' enabled=true()*}
{/if}
</div>
<!-- <div class="right">
    <input type="text" class="halfbox hide ezobject-relation-search-text" />
    <input type="submit" class="button hide ezobject-relation-search-btn" name="CustomActionButton[{$attribute.id}_browse_object]" value="{'Find object'|i18n( 'design/standard/content/datatype' )}" />
</div> -->
<div class="break"></div>
<div class="block inline-block ezobject-relation-search-browse hide"></div>
</div>
{include uri='design:content/datatype/edit/ezobjectrelation_ajax_search.tpl'}
</div>
{/case}




{* Dropdown list. *}
{case match=1}
{let parent_node=fetch( content, node, hash( node_id, $class_content.default_selection_node ) )}

<select id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}" class="ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" name="{$attribute_base}_data_object_relation_id_{$attribute.id}">
{if $attribute.contentclass_attribute.is_required|not}
<option value="" {if eq( $attribute.data_int, '' )}selected="selected"{/if}>{'No relation'|i18n( 'design/standard/content/datatype' )}</option>
{/if}
{section var=Nodes loop=fetch( content, list, hash( parent_node_id, $parent_node.node_id, sort_by, $parent_node.sort_array ) )}
<option value="{$Nodes.item.contentobject_id}" {if eq( $attribute.data_int, $Nodes.item.contentobject_id )}selected="selected"{/if}>{$Nodes.item.name|wash}</option>
{/section}
</select>

{if $class_content.fuzzy_match}
<input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}_fuzzy_match" class="ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="text" name="{$attribute_base}_data_object_relation_fuzzy_match_{$attribute.id}" value="" />
{/if}

{/let}
{/case}


{* Dropdown tree. Not implemented yet, thus unavailable from class edit mode. *}
{case match=2}
{/case}

{case/}

{/switch}

{/let}
{/default}
