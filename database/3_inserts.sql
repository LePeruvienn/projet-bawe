/**************************
* USERS TEST DATA INSERTION
***************************/
INSERT INTO users (username, email, password) VALUES (
	'FEUR',
	'feur@free.fr',
	'123'
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

INSERT INTO posts (user_id, content) VALUES (
	1,
	'Salut la team euuh je suis la et tout je suis feur et j''aime bien les chips en vrai et tout, vous en pensez quoi la team ?'
);
INSERT INTO posts (user_id, content) VALUES (
	2,
	'Quelqu''un connais un plan pour avoir du paté pas cher les gars, la j''ai trop faim'
);
INSERT INTO posts (user_id, content) VALUES (
	3,
	'Et hier j''était dans le bus et la ya ce gros tas de milou qui viens me parler de son paté de con putaint comment j''avais trop la haine'
);
INSERT INTO posts (user_id, content) VALUES (
	4,
	'@sarah ouvre moi la porte stp sinon je te promet que je gueule devant ta porte toute la nuit'
);
INSERT INTO posts (user_id, content) VALUES (
	5,
	'Je viens me passer à Paris Panem comment les flan vanille sont masterclass je me suis mit bien la'
);
