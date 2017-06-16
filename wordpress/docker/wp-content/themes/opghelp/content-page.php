<?php
/**
 * The template used for displaying page content
 *
 * @package WordPress
 * @subpackage Twenty_Fourteen
 * @since Twenty Fourteen 1.0
 */
?>

    <article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
        <?php
        // Page thumbnail and title.
        twentyfourteen_post_thumbnail();
        the_title( '<header class="entry-header"><h1 class="entry-title">', '</h1></header><!-- .entry-header -->' );
        ?>

        <section class="entry-content">

            <?php
            the_content();
            edit_post_link( __( 'Edit', 'twentyfourteen' ), '<span class="edit-link">', '</span>' );
            ?>

        </section><!-- .entry-content -->

        <div class="side-bar">

            <?php get_sidebar( 'content' ); ?>

            <aside class="most-popular">
                <h3>Most viewed information</h3>
                <?php
                wpp_get_mostpopular();
                ?>
            </aside>

            <aside class="request-change">
                <h3>
                    <a href="mailto:OPG_Content@publicguardian.gsi.gov.uk?subject=Request to change H%26G content">
                        <span class="opg-icon">Email</span>
                        Questions and feedback
                    </a>
                </h3>
            </aside>

        </div>
    </article><!-- #post-## -->

