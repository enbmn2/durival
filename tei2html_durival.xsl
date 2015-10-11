<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Titre      : Programme XSLT pour la transformation en XHTML simple de fichier TEI réalisé à partir de manuscrits
Auteur     : Florence Clavaud (Ecole nationale des chartes), Augmenté par Emmanuel Chateau
Audience     : participants à la formation sur TEI donnée an mars 2011 à l'Ecole des chartes
Conditions d'utilisation : licence Creative Commons paternité-pas d'utilisation commerciale-modification autorisée dans les mêmes conditions etc.
Date      : 10 mars 2011, relecture 12 avril 2011, adaptation xslt2 mai 2015
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output omit-xml-declaration="no" indent="yes" method="html" version="5.0" encoding="UTF-8"/>
  <!--<xsl:output omit-xml-declaration="no" indent="yes" method="xml" encoding="UTF-8"/>-->
  <!--<xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes" />-->

  <xsl:strip-space elements="*"/>

  <xsl:param name="commentaires"/>
  <xsl:template match="comment() | processing-instruction()"/>
  <xsl:template match="/TEI">
    <!-- on génère le squelette de la page HTML -->
    <html>
      <!-- métadonnées simples. Pourraient être complétées pour générer des balises meta en établissant une correspondance avec le modèle Dublin Core -->
      <head>
        <title>
          <xsl:value-of select="normalize-space(//titleStmt/title[1])"/>

        </title>
        <link rel="stylesheet" type="text/css" href="durival.css"/>
        <meta name="keywords" content="{keywords}"/>
        <link rel="copyright" href="{copyright}"/>
        <link href="css/main.css" rel="stylesheet"/>
        <script src="//code.jquery.com/jquery-2.1.4.min.js"/>
        <!-- ajouter js pour lt IE 9 -->
      </head>
      <!-- le corps de la page -->
      <body>
        <!-- une colonne à gauche, pour l'en-tête et l'image -->
        <div id="gauche">
          <div id="header">
            <!-- cette colonne ne contiendra que les informations bibliographiques -->
            <xsl:apply-templates select="teiHeader/fileDesc/titleStmt"/>
            <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt"/>
            <div id="metadonnees">
              <hr/>
              <xsl:apply-templates select="teiHeader/fileDesc/sourceDesc"/>
              <xsl:apply-templates select="teiHeader/encodingDesc/classDecl"/>
            </div>
          </div>
          <!-- on va placer les images numériques ici, ce n'est pt-être pas l'idéal, mais il y a de la place à cet endroit et on veut rester simple -->
          <div id="images">
            <img src="{descendant::div[@type='transcription']/@facs}" alt="" width="90%"/>
          </div>
        </div>
        <!-- une autre colonne, elle-même scindée en plusieurs parties, pour la table des matières, les métas du document, la transcription, etc.
        avec le lien vers la partie concernée-->
        <div id="droite">
          <div id="tdm">
            <ul>
              <li>
                <a>Sommaire</a>
              </li>
              <li>
                <a href="#transcription">Transcription</a>
              </li>
              <xsl:if test="$commentaires = 'oui'">
                <li>

                  <a href="#notes">Notes historiques</a>
                </li>
              </xsl:if>
              <xsl:if test="$commentaires = 'oui'">
                <li>
                  <a href="#commentaires">Commentaires</a>
                </li>
              </xsl:if>
              <li>
                <a href="#index">Index</a>
              </li>
              <li>
                <a href="#index-personnes">Index des noms de personnes</a>
              </li>
              <li>
                <a href="#index-lieux">Index des noms de lieux</a>
              </li>

            </ul>
          </div>
          <div id="body">
            <!-- cette colonne présente toute la substance composant l'édition du manuscrit, notes incluses -->

            <div id="transcription">
              <hr/>
              <h2>Transcription</h2>
              <xsl:apply-templates select="//div[@type = 'transcription']"/>
              <p>
                <a href="#tdm">Retour au début</a>
              </p>
            </div>
            <div id="notes">
              <hr/>
              <xsl:apply-templates select="text/back/div[@type = 'notes']"/>
              <p>
                <a href="#tdm">Retour au début</a>
              </p>
            </div>
            <xsl:if test="$commentaires = 'oui'">
              <div id="commentaires">
                <hr/>
                <h2>Commentaires</h2>
                <xsl:apply-templates select="text/body/div[@type = 'commentaires']"/>
                <p>
                  <a href="#tdm">Retour au début</a>
                </p>
              </div>
            </xsl:if>
          </div>
          <div id="index">
            <hr/>
            <h2>Index</h2>
            <!-- les index -->
            <xsl:apply-templates select="text/back/div[@type = 'index']"/>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>

  <!-- LES INFOS D'EN-TETE -->

  <xsl:template match="titleStmt">
    <div class="titleStmt">
      <p class="docTitle">
        <xsl:apply-templates select="title[1]"/>
      </p>
      <!-- A REVOIR -->
      <xsl:if test="author">
        <p class="author">
          <xsl:apply-templates select="author"/>
        </p>
      </xsl:if>
      <xsl:if test="principal">
        <p class="principal">
          <xsl:apply-templates select="principal"/>
        </p>
      </xsl:if>
      <xsl:if test="respStmt">
        <p class="respStmt">
          <span class="libelle">Contributeurs : </span>
          <xsl:for-each select="respStmt">
            <span class="respStmt">
              <xsl:apply-templates select="resp"/>

              <xsl:apply-templates select="name"/>

            </span>
            <xsl:if test="position() != last()">
              <xsl:text> ; </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </p>
      </xsl:if>
    </div>
  </xsl:template>
  <!-- dans le div spécifié ci-dessus, un paragraphe pour le titre, un autre pour l'auteur principal, un autre pour les responsabilités secondaires -->
  <xsl:template match="title[1]">
    <xsl:apply-templates/>
    <xsl:if test="following-sibling::title[@type = 'complement']">
      <xsl:value-of
        select="concat(' : ', normalize-space(following-sibling::title[@type = 'complement']))"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="principal | titleStmt/author">
    <xsl:text>Par </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="respStmt/name">
    <xsl:apply-templates/>
    <xsl:value-of select="concat('', ', ', '')"/>
  </xsl:template>

  <xsl:template match="funder">
    <div class="funder">
      <p>
        <xsl:apply-templates select="funder"/>

      </p>
    </div>
  </xsl:template>
  <xsl:template match="publicationStmt">
    <div class="publicationStmt">
      <p>
        <xsl:apply-templates select="publisher"/>
        <xsl:text>, </xsl:text>

        <xsl:apply-templates select="pubPlace"/>
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="date"/>
      </p>
    </div>
    <div class="availiblity">
      <p>
        <xsl:apply-templates select="availability"/>

      </p>
    </div>
  </xsl:template>
  <xsl:template match="publisher">
    <span class="publisher">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="address">
    <!-- si on ne veut pas que l'adresse de l'organisme responsable de la publication figure dans la sortie, il suffit de mettre le contenu de cette règle en commentaire, pour qu'elle soit vide -->
    <xsl:text> (</xsl:text>
    <xsl:apply-templates select="addrLine"/>
    <xsl:text>). </xsl:text>
  </xsl:template>
  <xsl:template match="publicationStmt/date">
    <span class="libelle">Date de publication : </span>
    <span class="date">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="addrLine">
    <xsl:apply-templates/>
    <xsl:if test="position() != last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>
  <!-- LES METAS DU DOCUMENT -->
  <xsl:template match="sourceDesc">
    <div class="sourceDesc">
      <xsl:apply-templates select="msDesc/msIdentifier"/>
      <xsl:apply-templates select="msDesc/msContents"/>

      <xsl:apply-templates select="msDesc/physDesc"/>
      <!-- à compléter éventuellement -->
    </div>
  </xsl:template>

  <!--      Description du MS-->
  <xsl:template match="msIdentifier">
    <p class="msIdentifier">
      <xsl:value-of
        select="concat(institution, ' - ', repository, ' (', country, ') : ', collection, ' ', idno, ', ', altIdentifier)"
      />
    </p>
  </xsl:template>
  <xsl:template match="physDesc">
    <div class="physDesc">
      <!-- <p class="msContents">-->
      <xsl:apply-templates/>
      <!-- </p>-->
    </div>
  </xsl:template>
  <xsl:template match="msContents">
    <div class="msContents">
      <!-- <p class="msContents">-->
      <xsl:apply-templates/>
      <!-- </p>-->
    </div>
  </xsl:template>


  <xsl:template match="summary">
    <p class="summary">
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <xsl:template match="textLang">
    <p class="textLang">
      <xsl:text>Langue du document : </xsl:text>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <xsl:template match="objectDesc">
    <p class="objectDesc">
      <xsl:apply-templates select="descendant::material"/>
      <xsl:text>, </xsl:text>
      <xsl:apply-templates select="descendant::dimensions"/>
      <xsl:text> ; </xsl:text>
      <xsl:apply-templates select="descendant::condition"/>
    </p>
  </xsl:template>
  <xsl:template match="dimensions">
    <xsl:value-of select="concat('larg. ', width, ' x haut. ', height, ' ', @unit)"/>
  </xsl:template>

  <!-- TRANSCRIPTION -->

  <xsl:template match="//div[@type = 'transcription']/div">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="//date">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!--  FIN TRANSCRIPTION -->

  <!--LES RENDUS-->

  <!--styles-->
  <xsl:template match="sic">
    <xsl:apply-templates/>
    <xsl:value-of select="concat(' ', '[sic]')"/>
  </xsl:template>

  <xsl:template match="reg">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="expan">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="abbr">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="ex">
    <xsl:value-of select="concat('(', normalize-space(.), ') ')"/>
  </xsl:template>

  <xsl:template match="fw">
    <p>
      <!--<xsl:value-of select="concat(' ', ' ')"/>-->
      <xsl:apply-templates/>
    </p>
  </xsl:template>


  <!--    liens sur les persName -->
  <xsl:template match="div[@type = 'transcription']//persName">
    <span class="persName">
      <xsl:choose>
        <xsl:when test="@ref[starts-with(., '#')]">
          <xsl:variable name="monRef">
            <xsl:value-of select="substring-after(@ref, '#')"/>
          </xsl:variable>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="normalize-space(@ref)"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of
                select="normalize-space(ancestor::text/back//listPerson/person[@xml:id = $monRef]/persName[@type = 'index'])"
              />
            </xsl:attribute>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>
  <!--    liens sur les placeName -->
  <xsl:template match="div[@type = 'transcription']//placeName">
    <span class="persName">
      <xsl:choose>
        <xsl:when test="@ref[starts-with(., '#')]">
          <xsl:variable name="monRef">
            <xsl:value-of select="substring-after(@ref, '#')"/>
          </xsl:variable>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="normalize-space(@ref)"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of
                select="normalize-space(ancestor::text/back//listPlace/place[@xml:id = $monRef]/persName[@type = 'index'])"
              />
            </xsl:attribute>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <!--lien sur rs-->

  <xsl:template match="div[@type = 'transcription']//rs">
    <span class="persName">
      <xsl:choose>
        <xsl:when test="@ref[starts-with(., '#')]">
          <xsl:variable name="monRef">
            <xsl:value-of select="substring-after(@ref, '#')"/>
          </xsl:variable>
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="normalize-space(@ref)"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of
                select="normalize-space(ancestor::text/back//listPerson/person[@xml:id = $monRef]/persName[@type = 'index'])"
              />
            </xsl:attribute>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>


  <!-- FIN LES RENDUS-->

  <!-- INDEX -->
  <xsl:template match="text/back/div[@type = 'index']">
    <div class="index-list" id="index-personnes">
      <xsl:apply-templates/>
      <p>
        <a href="#tdm">Retour au début</a>
      </p>
    </div>
    <div class="index-list" id="index-lieux">
      <xsl:apply-templates select="listPlace"/>
      <p>
        <a href="#tdm">Retour au début</a>
      </p>
    </div>
  </xsl:template>
  <xsl:template match="listPerson">
    <h3>Index des noms de personnes</h3>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="listPlace">
    <h3>Index des noms de lieux</h3>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- ci dessus affiche la liste -->
  <xsl:template match="person">
    <p class="person">
      <xsl:attribute name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <xsl:template match="place">
    <p class="place">
      <xsl:attribute name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:attribute>
      <xsl:apply-templates select="placeName"/>
    </p>
  </xsl:template>
  <!-- ci dessus détermine comment est affichée la liste à savoir un id un p -->

  <xsl:template match="lb">
    <br/>
  </xsl:template>

  <!-- retours à la ligne dans la page Web, chaque fois qu'il y a un changement de ligne dans le manuscrit -->
  <!-- -->
  <!-- Une règle qui s'appliquera à un élément si aucune autre instruction spécifique ne le concerne ; elle permet donc de voir ce qui reste à traiter ; pratique !! -->
  <xsl:template match="*">
    <!-- Attention, du CSS dans un attribut style est une
   mauvaise pratique, ne surtout pas imiter <span style="margin:0 0 0 1em">
  -->
    <span>
      <code style="color:red">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:for-each select="@*">
          <xsl:text> </xsl:text>
          <xsl:value-of select="name()"/>
          <xsl:text>="</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>"</xsl:text>
        </xsl:for-each>
        <xsl:text>&gt;</xsl:text>
      </code>
      <xsl:apply-templates/>
      <code style="color:red">&lt;/<xsl:value-of select="name()"/>&gt;</code>
    </span>
  </xsl:template>
</xsl:stylesheet>
