<div class="entry-meta">
			<span class="cat-links">
                <?php echo get_the_category_list( _x( ' > ', 'Used between list items, there is a space after the comma.', 'opghelp' ) ); ?>

                <?php
                if ( is_single() ) {
                    echo ' > ';
                    echo the_title( '<span class="currentPage">', '</span>');
                }
                ?>
            </span>
</div>