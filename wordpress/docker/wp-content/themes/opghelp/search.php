<?php
/**
 * The template for displaying Search Results pages
 *
 * @package    WordPress
 * @subpackage Twenty_Fourteen
 * @since      Twenty Fourteen 1.0
 */

get_header(); ?>

    <section id="primary" class="content-area">
        <div id="content" class="site-content" role="main">

            <?php if (have_posts()) : ?>

                <header class="page-header">
                    <h1 class="page-title"><?php printf(
                            __('Showing help and guidance for: <strong>%s</strong>', 'opghelp'),
                            get_search_query()
                        ); ?></h1>
                </header><!-- .page-header -->

                <?php
                // Start the Loop.
                while (have_posts()) : the_post();

                    /*
                     * Include the post format-specific template for the content. If you want to
                     * use this in a child theme, then include a file called called content-___.php
                     * (where ___ is the post format) and that will be used instead.
                     */
                    get_template_part('content', get_post_format());

                endwhile;
                // Previous/next post navigation.
                twentyfourteen_paging_nav();

            else :
                // If no content, include the "No posts found" template.
                get_template_part('content', 'none');

            endif;
            ?>

        </div>
        <!-- #content -->

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
                        <span class="opg-icon">CaseInfo</span>
                        Request a change to this guidance
                    </a>
                </h3>
            </aside>

        </div>

    </section><!-- #primary -->

<?php
get_footer();
