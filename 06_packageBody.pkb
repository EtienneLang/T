CREATE OR REPLACE PACKAGE BODY Q10_creer_package_traitement_cnc IS
    
    /**
    * Fonction qui sert à vérifier si un utilisateur existe.
    * Prends un id en paramètre et retourne un booléen en fonction de l'existance de l'utilisateur
    */
    FUNCTION Q1_utilisateur_existe_FCT(i_id_user IN NUMBER) RETURN BOOLEAN
    IS
        v_compteur NUMBER;
        v_reponse BOOLEAN;
    BEGIN
        -- Gestion d'erreur --
        IF i_id_user IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Paramètre NULL : L''ID utilisateur est NULL.');
        END IF;
        IF i_id_user < 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nombre négatif en paramètre : L''ID utilisateur est négatif.');
        END IF;
        -----------------------
        SELECT COUNT(*)
        INTO v_compteur
        FROM cnc.utilisateurs
        WHERE utilisateurid = i_id_user;
    
        IF v_compteur = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'L''ID passé en paramètre ne correspond à rien dans la base de données.');
        END IF;
    
        v_reponse := true;
    
        RETURN v_reponse;
    END Q1_utilisateur_existe_FCT;

    /**
    * Fonction qui valide si une annonce est disponible entre deux dates données.
    * Elle reçoit l'id de l'annonce désiré ainsi que les deux date à valider.
    * Retourne un booléen selon la disponibilité de l'annonce
    */
    FUNCTION Q2_annonce_est_disponible_FCT(i_id_annonce IN NUMBER, i_date_debut IN DATE, i_date_fin IN DATE) RETURN BOOLEAN
    IS
        v_compteur NUMBER;
        v_reponse BOOLEAN;
    BEGIN
        -- Gestion d'erreur --
        IF i_id_annonce IS NULL OR i_date_debut IS NULL OR i_date_fin IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Paramètre NULL : Un paramètre est NULL.');
        END IF;
        IF i_id_annonce < 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nombre négatif en paramètre : L''ID utilisateur est négatif.');
        END IF;
        IF i_date_fin < i_date_debut THEN 
            RAISE_APPLICATION_ERROR(-20003, 'Dates non valides : Date fin dois être plus grande que date début.');
        END IF;
        
        SELECT COUNT(*) INTO v_compteur
        FROM annonces WHERE annonceid = i_id_annonce;
        IF v_compteur = 0 THEN 
            RAISE_APPLICATION_ERROR(-20004, 'id de l''annonce ne correspond à aucune annonce');
        END IF;
        -----------------------
        SELECT COUNT(*)
        INTO v_compteur
        FROM reservations
        WHERE annonceid = i_id_annonce 
            AND ((i_date_debut BETWEEN datedebut AND datefin)
            OR (i_date_fin BETWEEN datedebut AND datefin));
                
        IF v_compteur = 0 THEN
            v_reponse := true;
        ELSE
            v_reponse := false;
        END IF;
        RETURN v_reponse;
    END Q2_annonce_est_disponible_FCT;
    
    /**
    * Fonction qui sert à calculer le total d'une facture.
    * Prends en paramètre l'id de l'annonce, la date d'arrivé, la date de départ ainsi que le nombre de personnes qui vont y rester.
    * Retourne le total pour une réservation demandé.
    */
    FUNCTION Q3_calculer_total_FCT(i_annonce_id IN NUMBER, i_date_debut IN DATE, i_date_fin IN DATE, i_nombre_personne IN NUMBER) RETURN NUMBER
    IS
        v_nombre_jours NUMBER;
        v_prix_par_nuit NUMBER;
        v_prix_base NUMBER;
        v_total NUMBER := 0;
        v_prix_nettoyage NUMBER := 0;
        v_prix_nettoyage_base NUMBER := 20;
        v_compteur NUMBER := 0;
    BEGIN
        -- Gestion d'erreurs --
        IF i_date_debut IS NULL OR i_date_fin IS NULL OR i_nombre_personne IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Paramètre NULL : L''ID utilisateur est NULL.');
        END IF;
        IF i_nombre_personne <= 0 THEN 
            RAISE_APPLICATION_ERROR(-20002, 'Nombre de personne non valide : Le nombre de personne doit être supérieur à 0.');
        END IF;
        IF i_date_fin < i_date_debut THEN 
            RAISE_APPLICATION_ERROR(-20003, 'Dates non valides : Date fin dois être plus grande que date début.');
        END IF;
        
        SELECT COUNT(*) INTO v_compteur
        FROM annonces WHERE annonceid = i_annonce_id;
        IF v_compteur = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'id de l''annonce ne correspond à aucune annonce');
        END IF;
        -----------------------
        v_nombre_jours := EXTRACT(DAY FROM NUMTODSINTERVAL(i_date_fin - i_date_debut, 'DAY'));
        SELECT prixparnuit INTO v_prix_par_nuit FROM annonces WHERE annonceid = i_annonce_id;
        v_prix_base := v_nombre_jours * v_prix_par_nuit;
        
        IF v_nombre_jours <= 2 THEN
            v_prix_nettoyage := v_nombre_jours * v_prix_nettoyage_base * i_nombre_personne; 
        ELSE
            v_prix_nettoyage := 2 * v_prix_nettoyage_base * i_nombre_personne;
            v_nombre_jours := v_nombre_jours - 2;
            WHILE v_nombre_jours > 0 LOOP
                v_prix_nettoyage_base := v_prix_nettoyage_base - 2;
                IF v_prix_nettoyage_base < 5 THEN
                    v_prix_nettoyage_base := 5;
                END IF;    
                v_prix_nettoyage := v_prix_nettoyage + (v_prix_nettoyage_base * i_nombre_personne);
                v_nombre_jours := v_nombre_jours - 1;
            END LOOP;
        END IF;
        v_total := v_prix_base + v_prix_nettoyage;
        RETURN v_total;
    END Q3_calculer_total_FCT;

    /**
    * Fonction qui sert a obtenir l'historique des messages échangés entre deux utilisateurs
    * Prends en paramètres l'id des deux utilisateurs
    * Retourne un VARRAY de messages (vide s'il n'y a pas de messages entre les deux utilisateurs)
    */
    FUNCTION Q4_obtenir_message_historique_FCT(i_id_user_1 IN NUMBER, i_id_user_2 IN NUMBER) RETURN t_message_varray
    AS
        messages t_message_varray := t_message_varray();
        v_compteur NUMBER;
    BEGIN
        --gestion d'erreur
        IF i_id_user_1 IS NULL OR i_id_user_2 IS NULL THEN 
            RAISE_APPLICATION_ERROR(-20001, 'Paramètre NULL : L''ID d''un utilisateur est NULL.');
        END IF;
        IF i_id_user_1 < 0 OR i_id_user_2 < 0 THEN 
            RAISE_APPLICATION_ERROR(-20002, 'L''id d''un des utilisateur est négatif');
        END IF;
        SELECT COUNT(*) INTO v_compteur FROM utilisateurs WHERE utilisateurid = i_id_user_1 OR utilisateurid = i_id_user_2;
        IF v_compteur != 2 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Un ou les deux utilisateurs n''existe(ent) pas dans la base de données');
        END IF;
        FOR message_trouve IN(
            SELECT * FROM messages
            WHERE (expediteurutilisateurid = i_id_user_1 AND destinataireutilisateurid = i_id_user_2)
            OR (expediteurutilisateurid = i_id_user_2 AND destinataireutilisateurid = i_id_user_1)
            ORDER BY dateenvoi
        )
        LOOP
        messages.EXTEND;
        messages(messages.LAST) := t_message(
            message_trouve.MessageID,
            message_trouve.ExpediteurUtilisateurID,
            message_trouve.DestinataireUtilisateurID,
            message_trouve.Contenu,
            message_trouve.DateEnvoi  
            );
        END LOOP;
        RETURN messages;
    END Q4_obtenir_message_historique_FCT;
    
    /**
    * Procédure qui sert à supprimer une annonce ainsi que toutes les autres choses qui lui sont reliées
    * Prends en paramètre l'id de l'annonce
    */
    PROCEDURE Q5_supprimer_annonce_PRC(i_id_annonce IN NUMBER)
    IS
        v_compteur NUMBER;
    BEGIN
        -- Gestion d'erreurs --
        IF i_id_annonce IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Paramètre NULL : Un paramètre est NULL.');
        END IF;
        IF i_id_annonce < 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nombre négatif en paramètre : L''ID annonce est négatif.');
        END IF;
        SELECT COUNT(*) INTO v_compteur FROM annonces WHERE annonceid = i_id_annonce;
        IF v_compteur = 0 THEN 
            RAISE_APPLICATION_ERROR(-20003, 'L''ID passé en paramètre ne correspond à rien dans la base de données.');
        END IF;
        
        -----------------------
        DELETE FROM cnc.reservations
        WHERE annonceid = i_id_annonce;
        DELETE FROM cnc.photos
        WHERE annonceid = i_id_annonce;
        DELETE FROM cnc.commentaires
        WHERE annonceid = i_id_annonce;
        DELETE FROM cnc.utilisateurs_annonces
        WHERE annonceid = i_id_annonce;
        DELETE FROM cnc.annonces
        WHERE annonceid = i_id_annonce;
    END Q5_supprimer_annonce_PRC; 

    /**
    * Procédure qui sert a réserver sur une annonce.
    * Prends en paramètres l'id de l'annonce, la date d'arrivé, la date de départ ainsi que le nombre de personnes qui vont séjourner
    */
    PROCEDURE Q6_reserver_PRC(i_id_annonce IN NUMBER, i_date_debut IN DATE, i_date_fin IN DATE, i_nombre_personne IN NUMBER)
    IS
        v_result BOOLEAN;
        v_total NUMBER;
        v_compteur NUMBER;
    BEGIN
        -- Gestion d'erreurs --
        IF i_id_annonce IS NULL OR i_date_debut IS NULL OR i_date_fin IS NULL OR i_nombre_personne IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Paramètre NULL : Un paramètre est NULL.');
        END IF;
        IF i_id_annonce < 0 OR i_nombre_personne < 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nombre négatif en paramètre');
        END IF;
        SELECT COUNT(*) INTO v_compteur FROM annonces WHERE annonceid = i_id_annonce;
        IF v_compteur = 0 THEN 
            RAISE_APPLICATION_ERROR(-20003, 'L''ID passé en paramètre ne correspond à rien dans la base de données.');
        END IF;
        IF i_date_fin < i_date_debut THEN 
            RAISE_APPLICATION_ERROR(-20004, 'Dates non valides : Date fin dois être plus grande que date début.');
        END IF;
        -----------------------
    
        v_result := Q2_annonce_est_disponible_FCT(i_id_annonce, i_date_debut, i_date_fin);
        IF v_result THEN 
            v_total := calculer_total_FCT(i_date_debut, i_date_fin, i_nombre_personne);
            INSERT INTO reservations(reservationid, annonceid, datedebut, datefin, statut, montanttotal) 
            VALUES (10, i_id_annonce, i_date_debut, i_date_fin, 'En Attente', v_total);
            DBMS_OUTPUT.PUT_LINE('valide');
        END IF;
    END Q6_reserver_PRC; 
    
    /**
    * Procédure qui affiche la conversation entre deux utilisateurs dans la console
    * Prends en paramètre l'id des deux utilisateurs concernés
    */
    PROCEDURE Q7_afficher_converstation_PRC(i_id_user1 NUMBER, i_id_user2 NUMBER)
    AS
        messages t_message_varray;
        nom_utilisateur VARCHAR2(100);
    BEGIN
        messages := Q4_obtenir_message_historique_FCT(i_id_user1, i_id_user2);
        IF messages.COUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Aucun message trouvé entre les deux utilisateurs');
        ELSE
            FOR i in 1..messages.COUNT LOOP
                SELECT prenom || ' ' || nom INTO nom_utilisateur
                FROM utilisateurs WHERE utilisateurid = messages(i).ExpediteurUtilisateurID;
                DBMS_OUTPUT.PUT_LINE(nom_utilisateur || ' : ' || messages(i).Contenu || ' - envoyé le ' || TO_CHAR(messages(i).DateEnvoi, 'YYYY-MM-DD HH24:MI:SS'));
            END LOOP;
        END IF;
    END Q7_afficher_converstation_PRC;
    
    /**
    * Procédure qui affiche dans la console le revenue de chaque localisation distincte dans la table annonces
    */
    PROCEDURE Q8_revenu_par_localisation_PRC
    AS 
        TYPE dict_localisation_revenu IS TABLE OF NUMBER INDEX BY VARCHAR2(200);
        revenus_par_localisation dict_localisation_revenu;
        cle_localisation VARCHAR2(200);
        total_revenue NUMBER;
    BEGIN
        revenus_par_localisation := dict_localisation_revenu();
        
        FOR endroit IN (SELECT DISTINCT localisation FROM annonces) LOOP
            revenus_par_localisation(endroit.localisation) := 0;
        END LOOP;
        
        FOR endroit in (
            SELECT localisation, SUM(montantTotal) as total_revenue
            FROM annonces a
            JOIN reservations r ON a.annonceid = r.annonceid
            GROUP BY localisation
        )LOOP
            revenus_par_localisation(endroit.localisation) := endroit.total_revenue;
        END LOOP;
        
        cle_localisation := revenus_par_localisation.FIRST;
        WHILE cle_localisation IS NOT NULL LOOP
            DBMS_OUTPUT.PUT_LINE(cle_localisation || ' : ' || revenus_par_localisation(cle_localisation) || '$');
            cle_localisation := revenus_par_localisation.NEXT(cle_localisation);
        END LOOP;
    END Q8_revenu_par_localisation_PRC;
    
    /**
    * Procédure qui affiche à chaque annonce chacune des réservations fait par un utilisateur sur cette dernière
    */
    PROCEDURE Q9_reservation_par_usager_par_annonce_PRC 
    IS
        utilisateur utilisateurs%ROWTYPE;
    BEGIN
        FOR annonce IN (SELECT * FROM annonces)
        LOOP
            DBMS_OUTPUT.PUT_LINE('Annonce ID : ' || annonce.annonceid);
            DBMS_OUTPUT.PUT_LINE('Titre : ' || annonce.titre);
            DBMS_OUTPUT.PUT_LINE('Utilisateurs & réservations :');
            FOR utilisateur_id IN (SELECT DISTINCT utilisateurid FROM reservations r WHERE r.annonceid = annonce.annonceid)
            LOOP
                SELECT * INTO utilisateur FROM utilisateurs WHERE utilisateurid = utilisateur_id.utilisateurid;
                DBMS_OUTPUT.PUT_LINE('------------------------------------');
                DBMS_OUTPUT.PUT_LINE('Utilisateur ID : ' || utilisateur.utilisateurid);
                DBMS_OUTPUT.PUT_LINE('Utilisateur Nom : ' || utilisateur.prenom || ' ' || utilisateur.nom);
                FOR reservation IN (SELECT * FROM reservations WHERE annonceid = annonce.annonceid AND utilisateurid = utilisateur.utilisateurid)
                LOOP
                    DBMS_OUTPUT.PUT_LINE('--');
                    DBMS_OUTPUT.PUT_LINE('Réservation ID : ' || reservation.reservationid);
                    DBMS_OUTPUT.PUT_LINE('Date début : ' || reservation.datedebut);
                    DBMS_OUTPUT.PUT_LINE('Date fin : ' || reservation.datefin);
                END LOOP;
            END LOOP;
            DBMS_OUTPUT.PUT_LINE(' ');
            DBMS_OUTPUT.PUT_LINE(' ');
        END LOOP;
    END Q9_reservation_par_usager_par_annonce_PRC;
END Q10_creer_package_traitement_cnc;