<?php
/**
 * The default template for displaying content
 *
 * Used for both single and index/archive/search.
 *
 * @package OPG_Help_Preview
 */
?>

<article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
	<header class="entry-header">
        <?php if ( in_array( 'category', get_object_taxonomies( get_post_type() ) ) && twentyfourteen_categorized_blog() ) : ?>
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
		<?php
			endif;

			if ( is_single() ) :
				the_title( '<h1 class="entry-title">', '</h1>' );
			else :
				the_title( '<h1 class="entry-title"><a href="' . esc_url( get_permalink() ) . '" rel="bookmark">', '</a></h1>' );
			endif;
		?>

	</header><!-- .entry-header -->

	<?php if ( is_search() ) : ?>
	<div class="entry-summary">
		<?php the_excerpt(); ?>
	</div><!-- .entry-summary -->
	<?php else : ?>
	<div class="entry-content">
		<?php
			the_content( __( 'Continue reading <span class="meta-nav">&rarr;</span>', 'twentyfourteen' ) );
		?>
	</div><!-- .entry-content -->
	<?php endif; ?>

    <?php
    wp_nav_menu( array(
        'theme_location' => 'primary',
        'sub_menu' => true
    ) );
    ?>

</article><!-- #post-## -->
