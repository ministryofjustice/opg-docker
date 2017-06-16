<?php
/*
Template Name: Homepage
*/
get_header();
?>
    <h1 class="accessible-text">Homepage</h1>

    <article id="primary" class="content-area">

        <div class="site-content">

            <section class="child-pages">
                <?php

                $args = array(
                    'post_type' => 'page',
                    'tag' => 'landing-page'
                );

                // The Query
                $the_query = new WP_Query($args);

                // The Loop
                if ($the_query->have_posts()) {
                    while ($the_query->have_posts()) {
                        $the_query->the_post();
                        echo '<section><h2><a href="' . get_the_permalink() . '">' . get_the_title() . '</a></h2>';
                        if (get_the_excerpt()) {
                            echo '<p class="excerpt">' . get_the_excerpt() . '</p>';
                        }
                        echo '</section>';
                    }
                }
                ?>

                <section class="request-change">
                    <h2>
                        <a href="mailto:OPG_Content@publicguardian.gsi.gov.uk?subject=Request to change H%26G content">
                            <span class="opg-icon">CaseInfo</span>
                            Request a change to this guidance
                        </a>
                    </h2>
                </section>
            </section>

        </div>

        <div class="homepage-footer">

            <aside class="most-popular">
                <h2>Most viewed information</h2>
                <?php
                wpp_get_mostpopular();
                ?>
            </aside>

            <aside>
                <?php the_widget( 'OPG_Recently_Updated_Pages', array (
                    'title'             => 'Recent Updates',
                    'totalPagesToShow'  => 8,
                    'showListWithPosts' => 0,
                    'displayDate'       => 1,
                    'dateFormat'        => 'jS F Y',
                    'scDateFormat'      => 'jS F\'y \a\t g:ia',
                    'withFirstLine'     => 1
                ) ); ?>
            </aside>

            <nav class="primary-nav">
                <h2>Menu</h2>
                <?php wp_nav_menu( array('menu' => 'homepage' )); ?>
            </nav>

        </div>

    </article>
<?php
get_footer();

