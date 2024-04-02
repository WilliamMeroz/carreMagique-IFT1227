#
# Le programme doit générer une matrice 4x4 à partir de 16 nombres fournis par l'utilisateur, afficher cette matrice
# dans la console et ensuite indiquer à l'utilisateur si la matrice fournie est un carré magique ou non. 
# Pour ce faire, le programme doit faire la somme des éléments de chaque lignes, colonnes; 
# diagonales et coins pour ensuite les comparer. Si les sommes sont les mêmes, la matrice est un carré magique. 
# Le programme doit également performer de la validation pour chacun des nombres entrés par l'utilisateur 
# afin de s'assurer que ceux-ci ne soient pas répétés ou en dehors de la plage de nombres permise.
#	
# But: Indiquer si une matrice donnée par l'utilisateur est un carrée magique.
#
# Date: 02/03/2024
#
# Auteur: William Méroz-Moreau
# Courriel: william.meroz-moreau@umontreal.ca
# Matricule: 20249713
# Code permanent: MERW68100002 
#

.data
	valeurMinimum: .word 1
	valeurMaximum: .word 16

	messageInput: .asciiz "Entrez un nombre: "
	messageErreurPlageNombres: .asciiz "La valeur entrée doit être entre 1 et 16. Réessayez.\n"
	messageErreurValeurNonUnique: .asciiz "La valeur entrée doit être unique. Réessayez.\n"
	messageSuccesCreationMatrice: .asciiz "Les valeurs ont été ajoutées avec succès.\n"
	messageMatriceMagique: .asciiz "La matrice est un carré magique!\n"
	messageValeurMatriceMagique: .asciiz "La valeur magique est: "
	messageMatriceNonMagique: .asciiz "La matrice n'est pas un carré magique.\n"

.text


main:
	# Appel creerMat(0x10040000, 4, 4)
	addi $a0, $0, 0x10040000
	addi $a1, $0, 4
	addi $a2, $0, 4
	jal creerMat
	jal afficherMat
	jal estMagique

	li $v0, 10 # Terminer le programme
	syscall	

# creerMat(adresse, nbTs, nbCs)
creerMat:
	subi $sp, $sp, 16
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)


	# Calculons la dimension de la matrice et mettons-là dans $t0
	mult $a1, $a2
	mflo $s0 

	# Copions l'adresse dans un registre
	move $s1, $a0
	
	# On veut un tableau de 16 * 4 octets de taille (4 octets par nombre)
	sll $t0, $s0, 2 # 64 octets
	
	# Adresse de la matrice de vérification
	add $s2, $s1, $t0
	
	addi $s3, $0, 0 # Compteur pour le contrôle de la boucle
	addi $s4, $0, 1 # Variable de comparaison

	Verificationfor: bge $s3, $s0, verificationForEnd
	
		# Prompt pour utilisateur
		li $v0, 4
		la $a0, messageInput
		syscall
		
		li $v0, 5
		syscall
		
		move $s5, $v0
		
		# Arguments pour l'appel de verifierValeur
		move $a0, $s5
		move $a1, $s2
		
		jal verifierValeur
		
		bne $v0, $s4, erreurVerification
			# Ajouter la valeur à la matrice
			sw $s5, 0($s1)
			
			# Ajoutons un offset de 4 octets pour l'ajout de la prochaine valeur.
			addi $s1, $s1, 4
		
			# Incrémenter le compteur
			addi $s3, $s3, 1
		
		erreurVerification:
			j Verificationfor
	verificationForEnd: 
	
	li $v0, 4
	la $a0, messageSuccesCreationMatrice
	syscall
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	addi $sp, $sp, 16
	
	jr $ra

# verifierValeur(valeur, adresseMatriceValidation)
verifierValeur:

	subi $sp, $sp, 24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	
	lw $t0, valeurMinimum
	lw $t1, valeurMaximum
	
	blt $a0, $t0, inputPasDansLaPlage
	
	bgt $a0, $t1, inputPasDansLaPlage

	
	# Offset de l'élément de la matrice de vérification
	sll $t2, $a0, 2
	
	# Adresse de la valeur dans la matrice de vérification
	add $s0, $a1, $t2
	
	lw $s1, 0($s0)
	bne $s1, 0, inputPasUnique
	
	# Valeur est unique, donc on ajoute une valeur non-nul dans l'emplacement de la matrice de vérification
	sw $a0, 0($s0)
	
	li $v0, 1
	j finVerification
	
inputPasDansLaPlage:
	li $v0, 4
	la $a0, messageErreurPlageNombres
	syscall
	
	li $v0, 0
	j finVerification

inputPasUnique:
	li $v0, 4
	la $a0, messageErreurValeurNonUnique
	syscall
	
	li $v0, 0
	j finVerification

finVerification:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)

	addi $sp, $sp, 24

	jr $ra

# afficherMat(adrMatrice, nbRs, nbCs)
afficherMat:
	subi $sp, $sp, 24
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)


	move $s0, $a0
	move $s1, $a1
	move $s2, $a2

	# Pour chaque lignes, affichons tous les éléments des colonnes à cette ligne
	
	li $t0, 0 # Compteur lignes
	li $t1, 0 # Compteur colonnes
	forLignes: bge $t0, $s1, endForLignes
	forColonnes: bge $t1, $s2, endForColonnes
	
	lw $t2, 0($s0)
	
	li $v0, 1
	move $a0, $t2
	syscall
	
	li $v0, 11
	li $a0, 9
	syscall
	
	addi $s0, $s0, 4
	addi $t1, $t1, 1
	
	j forColonnes
	
	endForColonnes:
		li $v0, 11
		li $a0, 10
		syscall
		
		addi $t0, $t0, 1
		li $t1, 0
		j forLignes
	endForLignes:
	
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $s0, 12($sp)
	lw $s1, 16($sp)
	lw $s2, 20($sp)
	addi $sp, $sp, 24
	
	jr $ra

# estMagique(adrMatrice, nbRs, nbCs)
estMagique:
	subi $sp, $sp, 28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	

	jal verifierLignes
	move $s0, $v0

	jal verifierColonnes
	move $s1, $v0
	
	jal verifierDiagonales
	move $s2, $v0
	
	jal verifierCoins
	move $s3, $v0
	
	add $s4, $s0, $s1
	add $s4, $s4, $s2
	add $s4, $s4, $s3
	
	mult $s0, $a1
	mflo $s5
	
	bne $s4, $s5, matriceNonMagique
	j matriceMagique

matriceNonMagique:
	li $v0, 4
	la $a0, messageMatriceNonMagique
	syscall
	
	j finMatriceMagique

matriceMagique:
	li $v0, 4
	la $a0, messageMatriceMagique
	syscall
	
	la $a0, messageValeurMatriceMagique
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
		
	j finMatriceMagique	

finMatriceMagique:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	
	addi $sp, $sp, 28
			
	jr $ra

# verifierLignes(adrMatrice, nbRs, nbCs)	
verifierLignes:
	subi $sp, $sp, 16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2

	# Commençons par calculer la somme des éléments de la première ligne et utilisons-là comme valeur de comparaison.
	li $s3, 0
	li $t0, 0
bouclePremiereLigne: 
	bge $t0, $s2, endBouclePremiereLigne
	lw $t1, 0($s0)
	
	# Incrémentons l'adresse de 4 octets pour passer à la prochaine valeur.
	addi $s0, $s0, 4
	
	# Ajoutons la valeur à la somme totale et incrémentons notre compteur.
	add $s3, $s3, $t1
	addi $t0, $t0, 1
	j bouclePremiereLigne
	
endBouclePremiereLigne:
	# Maintenant on peut calculer les sommes des autres lignes et les comparer à notre première somme.
	
	# Retirons une ligne du nombre de lignes à parcourir 
	subi $s1, $s1, 1
	li $t2, 0 # Compteur pour la boucle des autres lignes.
	
boucleAutresLignes: 
	bge $t2, $s1, endBoucleAutresLignes
	li $t3, 0 # Compteur pour la boucle interne de la boucle des autres lignes
	li $t4, 0 # Variable qui contient la somme des éléments d'une ligne
	j innerBoucleAutresLignes
	
innerBoucleAutresLignes:
	bge $t3, $s2, endInnerBoucleAutresLignes
	lw $t1, 0($s0)
	add $t4, $t4, $t1 # Ajoutons l'élément à la somme de la ligne
	addi $s0, $s0, 4 # Incrémentons notre adresse de 4 octets
	addi $t3, $t3, 1 # Incrémentons notre compteur de 1
	j innerBoucleAutresLignes

endInnerBoucleAutresLignes:
	# Comparons la somme à la somme de la première ligne	
	bne $t4, $s3, lignesNonEgales
	addi $t2, $t2, 1
	j boucleAutresLignes

lignesNonEgales:
	li $v0, -1
	j finVerifierLignes

endBoucleAutresLignes:
	# Toutes les sommes des éléments des lignes sont les mêmes.
	move $v0, $s3
	j finVerifierLignes
finVerifierLignes:
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	
	addi $sp, $sp, 16
	jr $ra

# verifierColonnes(adrMatrice, nbRs, nbCs)	
verifierColonnes:
# Nous allons utiliser la même logique que dans la fonction de vérification des sommes des lignes. 
# Commençons par prendre la somme de la première colonne, pour ensuire la comparer aux autres sommes.
	subi $sp, $sp, 20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)	
	sw $s4, 16($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	li $t0, 0 # Compteur pour la première boucle de sommation.
	li $s3, 0 # Variable pour stocker la première somme trouvée.
	move $s4, $s0 # Faisons une copie de l'adresse originale
bouclePremiereColonne:
	bge $t0, $s2, endBouclePremiereColonne
	lw $t1, 0($s0) 
	add $s3, $s3, $t1
	addi $s0, $s0, 16 # On incrémente l'adresse de 16 octets cette fois pour passer au prochain élément de la colonne.
	addi $t0, $t0, 1 # On incrémente le compteur de la boucle.
	j bouclePremiereColonne

endBouclePremiereColonne:
	# On a maintenant une somme $s3 pour comparer aux sommes des autres colonnes.
	# Retirons une colonne à vérifier
	subi $s2, $s2, 1
	li $t1, 0 # Compteur pour la boucle de vérification des autres colonnes.
boucleAutresColonnes:
	bge $t1, $s2, endBoucleAutresColonnes
	addi $s4, $s4, 4
	move $s0, $s4
	li $t2, 0 # Compteur pour la boucle interne
	li $t3, 0 # Variable pour contenir les sommes des éléments des colonnes
innerBoucleAutresColonnes:
	bge $t2, $s1, endInnerBoucleAutresColonnes
	lw $t4, 0($s0)
	add $t3, $t3, $t4
	addi $t2, $t2, 1
	addi $s0, $s0, 16
	j innerBoucleAutresColonnes
	
endInnerBoucleAutresColonnes:
	# Comparons la somme obtenue avec la valeur de comparaison.
	bne $t3, $s3, colonnesNonEgales
	addi $t1, $t1, 1
	j boucleAutresColonnes

colonnesNonEgales:
	li $v0, -1
	j finVerifierColonnes

endBoucleAutresColonnes:
	move $v0, $s3
	j finVerifierColonnes
	
finVerifierColonnes:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)	
	lw $s4, 16($sp)
	addi $sp, $sp, 20
	
	jr $ra


# verifierDiagonales(adrMatrice, nbRs, nbCs)	
verifierDiagonales:

	subi $sp, $sp, 28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)	
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2

	li $t0, 0 # Compteur pour la boucle
	li $s4, 0 # Variable pour conserver la somme des éléments de la première diagonale.
	li $s5, 0 # Variable pour conserver la somme des éléments de la deuxième diagonale.
	subi $s6, $s2, 1
boucleDiagonale: 
	bge $t0, $s1, endBoucleDiagonale
	mult $t0, $s2 # i * m
	mflo $t3 # $t3 = i * m
	add $t4, $t3, $t0 # $t3 = i * m + j
	add $t5, $t3, $s6 # $t5 = i * m + jDiagonaleInverse
	
	sll $t4, $t4, 2 # * taille élement (4)
	add $t4, $t4, $s0 # $t3 = tab + (i * m + j) * taille élément

	sll $t5, $t5, 2
	add $t5, $t5, $s0 # $t5 = tab + (i * m +jDiagonaleInverse) * taille élément

	lw $t6, 0($t4)
	lw $t7, 0($t5)
	
	add $s4, $s4, $t6
	add $s5, $s5, $t7
	
	addi $t0, $t0, 1
	subi $s6, $s6, 1
	j boucleDiagonale

endBoucleDiagonale:
	bne $s4, $s5, diagonalesNonEgales
	move $v0, $s4
	j finVerifierDiagonales

diagonalesNonEgales:
	li $v0, -1
	j finVerifierDiagonales

finVerifierDiagonales:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)	
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	
	addi $sp, $sp, 28
	
	jr $ra
	
verifierCoins:	
	subi $sp, $sp, 8
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	subi $s0, $a1, 1
	subi $s1, $a2, 1

	# Coin haut gauche
	lw $t0, 0($a0)
	
	# Coin haut droit (i = 0, m = 4, j = 3)
	sll $t1, $s1, 2 # j * taille élément
	add $t2, $t1, $a0 # + tab
	lw $t1, 0($t2)
	
	# Coin bas gauche (i = 3, m = 4, j = 0)
	mult $s0, $a2 # i * m
	mflo $t2
	sll $t3, $t2, 2 # * 4 octets
	add $t4, $t3, $a0 # + tab
	lw $t3, 0($t4)
	
	# Coin bas droit (i = 3, m = 4, j = 3)
	
	add $t4, $t2, $s1 # i * m + j
	sll $t6, $t4, 2 # * 4 octets
	add $t6, $t6, $a0 # + tab
	lw $t4, 0($t6)
	
	add $v0, $t0, $t1
	add $v0, $v0, $t3
	add $v0, $v0,$t4
		
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra
