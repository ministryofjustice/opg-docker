<!-- custom search form component -->
<?php
    $searchValue = (isset($_REQUEST['s'])) ? $_REQUEST['s'] : '';
?>
<div>
    <form role="search" method="get" id="searchform" action="<?php echo home_url( '/' ); ?>">
        <div>
            <input type="submit" id="searchsubmit" value="Search" class="search-submit opg-icon">
            <label class="accessible-text" for="s">Search for:</label>
            <input type="text" value="<?php echo esc_attr_x($searchValue, 'value');?>" name="s" id="s" class="search-input">
        </div>
    </form>
</div>
