{let content=$class_attribute.content}
<div class="block">
<label for="eccaor_selection_{$class_attribute.id}">{'Selection method'|i18n( 'design/standard/class/datatype' )}:</label>
<select id="eccaor_selection_{$class_attribute.id}" name="ContentClass_ezobjectrelation_selection_type_{$class_attribute.id}">
    <option value="0" {eq( $content.selection_type, 0 )|choose( '', 'selected="selected"' )}>{'Browse'|i18n( 'design/standard/class/datatype' )}</option>
    <option value="1" {eq( $content.selection_type, 1 )|choose( '', 'selected="selected"' )}>{'Drop-down list'|i18n( 'design/standard/class/datatype' )}</option>
</select>
</div>
{/let}
