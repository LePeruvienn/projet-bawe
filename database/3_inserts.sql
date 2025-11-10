/**************************
* USERS TEST DATA INSERTION
***************************/
INSERT INTO users (username, email, password, is_admin) VALUES (
	'FEUR',
	'feur@free.fr',
	'123',
  TRUE
);
INSERT INTO users (username, email, password) VALUES (
	'Milou',
	'pate@manger.fr',
	'patepate'
);
INSERT INTO users (username, email, password) VALUES (
	'Babou',
	'meme@miaow.fr',
	'jaimepasmilou'
);
INSERT INTO users (username, email, password) VALUES (
	'Minette',
	'chipie@miaow.fr',
	'jesuismims'
);
INSERT INTO users (username, email, password) VALUES (
	'Sarah',
	'saraaaah@gmail.com',
	'parispanem'
);

/**************************
* POSTS TEST DATA INSERTION
***************************/

INSERT INTO posts (user_id, content, likes_count) VALUES (
	1,
	'Salut la team euuh je suis la et tout je suis feur et j''aime bien les chips en vrai et tout, vous en pensez quoi la team ?',
	12
);
INSERT INTO posts (user_id, content, likes_count) VALUES (
	2,
	'Quelqu''un connais un plan pour avoir du paté pas cher les gars, la j''ai trop faim',
	19
);
INSERT INTO posts (user_id, content, likes_count) VALUES (
	3,
	'Et hier j''était dans le bus et la ya ce gros tas de milou qui viens me parler de son paté de con putaint comment j''avais trop la haine',
	18
);
INSERT INTO posts (user_id, content, likes_count) VALUES (
	4,
	'@sarah ouvre moi la porte stp sinon je te promet que je gueule devant ta porte toute la nuit',
	14
);
INSERT INTO posts (user_id, content, likes_count) VALUES (
	5,
	'Je viens me passer à Paris Panem comment les flan vanille sont masterclass je me suis mit bien la',
	51
);
