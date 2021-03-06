const reviews = [
    {
        author: 'Linasa',
        date: '23 sept. 2018',
        message: 'Très belle application, <strong>contenu synthétique</strong> et bien expliqué, devs au top 🙂',
        rating: 5,
        source: 0,
    },
    {
        author: 'F. Chibaco',
        date: '15 août 2019',
        message: 'Merci beaucoup, cette appli est <strong>très bien expliquée</strong>. Merci encore. Et ça mérite plus de 5 étoiles.',
        rating: 5,
        source: 0,
    },
    {
        author: 'L. Saez',
        date: '28 sept. 2019',
        message: 'Des développeurs <strong>à l\'écoute</strong> qui prennent en compte les commentaires, je mets donc 5 étoiles.',
        rating: 5,
        source: 0,
    },
    {
        author: 'D. Mendes',
        date: '8 oct. 2019',
        message: 'Franchement <strong>merci</strong>, vous aidez beaucoup de monde.',
        rating: 5,
        source: 0,
    },
    {
        author: 'M. Daffe',
        date: '13 nov. 2019',
        message: 'L\'application est bonne car <strong>tout est détaillé</strong> avec des exemples précis, ça mérite plus que 5 étoiles.',
        rating: 5,
        source: 0,
    },
    {
        author: 'Ilyes',
        date: '10 fev. 2020',
        message: '<strong>J\'adore</strong> cette application ! Elle m\'aide beaucoup à réviser avant mes devoirs. Merci !',
        rating: 5,
        source: 0,
    },
    {
        author: 'A. Lamah',
        date: '13 fev. 2020',
        message: 'Très bon merci beaucoup, <strong>cela m\'a beaucoup aidé</strong> à former mes enfants. Félicitations au développeur.',
        rating: 4,
        source: 0,
    },
    {
        author: 'F. Calvez',
        date: '24 fev. 2020',
        message: '<strong>Très bonne application.</strong> Bravo au développeur.',
        rating: 5,
        source: 0,
    },
    {
        author: 'F. Calvez',
        date: '24 fev. 2020',
        message: '<strong>Très bonne application.</strong> Bravo au développeur.',
        rating: 5,
        source: 0,
    },
    {
        author: 'R. Belgique',
        date: '7 avr. 2020',
        message: '<strong>Vraiment super.</strong> Merci.',
        rating: 5,
        source: 0,
    },
    {
        author: 'S. Simon',
        date: '3 juin 2020',
        message: "<strong>J'adore</strong> cette appli. Je suis en terminale, j'ai 17 ans et je suis fan ; elle est parfaite sur le cours, les leçons, etc...",
        rating: 5,
        source: 0,
    }
];

let currentReviewIndex;

$(document).ready(showRandom);

function showRandom() {
    let reviewBox = $('.review');
    reviewBox.animate({
        opacity: 0,
    }, 200, function() {
        let currentReview = pickRandom();
        let stars = '';
        for(let star = 0; star < currentReview.rating; star++) {
            stars += '<i class="fa fa-star" aria-hidden="true"></i>';
        }
        for(let emptyStar = 0; emptyStar < (5 - currentReview.rating); emptyStar++) {
            stars += '<i class="fa fa-star-o" aria-hidden="true"></i>';
        }
        stars += '';
        reviewBox.find('.rating').html(stars);

        let author = currentReview.author + ', le ' + currentReview.date + ' sur ';
        switch(currentReview.source) {
            case 0:
                author += '<a href="https://play.google.com/store/apps/details?id=fr.bacomathiques&utm_source=bacomathiqu.es">Google Play</a>';
                break;
            case 1:
                author += 'l\'<a href="https://itunes.apple.com/app/id1458503418">App Store</a>';
                break;
        }
        author += '.';

        reviewBox.find('.content').html(currentReview.message);
        reviewBox.find('.author').html(author);
        reviewBox.animate({
            opacity: 1,
        }, 200, function() {
            setTimeout(showRandom, 5000);
        });
    });
}

function pickRandom() {
    let index;
    do {
        index = Math.floor(Math.random() * reviews.length);
    }
    while(index === currentReviewIndex);
    currentReviewIndex = index;
    return reviews[index];
}