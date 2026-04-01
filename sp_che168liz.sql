-- sp_che168   Procedimiento Unifica Agente 
-- creado: 07/02/2018 - Autor: Henry Girón.

DROP PROCEDURE sp_che168;
CREATE PROCEDURE "informix".sp_che168(a_agente CHAR(8))
                  RETURNING SMALLINT,char(8);  

DEFINE _cod_agente        CHAR(8);
DEFINE _error		      INTEGER;
DEFINE _error_mess 	      CHAR(50);
define _unificar        smallint;

let _cod_agente = "";
let _unificar = 0;

set isolation to dirty read;
--set debug file to "sp_che168.trc";
--trace on;
let _error = 0;
let _error_mess = '';
let _cod_agente = a_agente;
begin
on exception set _error
	return _error,_error_mess;  
end exception
		{if _cod_agente in('02550') then 		--Unificar AIE SEGUROS con Ezequiel Urrutia. se pone en comentario 17/07/18 correo enviado Jesus
		    let _cod_agente = "02219";
		end if}
		if _cod_agente in('01459') then 		--Unificar Magda Crespo codigo anterior con el nuevo codigo de ella.
		    let _cod_agente = "02547";
		end if
		if _cod_agente in('02243') then 		--Unificar Inversiones y Seguros Panamericanos, S. A. (CH) a Inversiones y Seguros Panamericanos, S. A.
		    let _cod_agente = "00473";
		end if
	    if _cod_agente in('01481') then 		--Unificar Jose Caballero a Marta Caballero
		    let _cod_agente = "01555";
		end if
		--****OJO PUESTO TEMPORALMENTE PARA VER LOS NUMERO DE ELLA, LUEGO QUITARLO***----
		if _cod_agente in('02302','02354') then --Unificar LIZSENELL GIONELLA BERNAL RAMIREZ, correo 24/03/17 Alicia. Se quita unificacion correo Analisa 19/02/2018
		    let _cod_agente = "02319";
		end if
		if _cod_agente in('01480') then --Unificar Ricardo Caballero, a Patricia Caballero
		    let _cod_agente = "01479";
		end if
		if _cod_agente in('02129','02130','02050','01001','01000','01002','01609','01005') then --Unificar Felix Abadia
		    let _cod_agente = "01001";
		end if
		if _cod_agente in('00288','02161','02379') then --Unificar Osacar andrade cubilla, Oscar Andrade Cubilla Panamá y Oscar xavier Andrade a ANDRADE 00816, correo Analisa 29/01/2018
		    let _cod_agente = "00816";
		end if
        let _unificar = 0;	 --Unificar FF Seguros	:25/04/2013 Leticia
		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado = "01068";
		if _unificar <> 0 then
		   let _cod_agente = "01068";
		end if
        let _unificar = 0;	 --Unificar SOMOS SEGUROS	:08/05/2017 Correo de Analiza.
		SELECT count(*)
		  INTO _unificar
		  FROM agtagent 
		 WHERE cod_agente      = _cod_agente
		   AND agente_agrupado = "02420";
		if _unificar <> 0 then
		   let _cod_agente = "02420";
		end if		   
 	    --1  Jovani Mora(00636), Quitza Paz(00732),  Alberto Camacho (00731) a Servicios Internacionales (01435)	 --
	    --se quita a Rogelio Becerra (00865) segun correo de Analisa del 23/05/2017
	    if _cod_agente in ("00636","00732","00731") then
		  let _cod_agente = "01435";
		end if
		--3 Doulos Insurance Consultants  (DICSA)(01048,01837) ,Logos Insurance(01569,01838), Juan Carlos Sanchez(01315,01834), Chung Wai Chun(00623,01836), Katia Mariza Dam de Spagnuolo(01575,01835)
		-- Se agregan los siguientes segun correo de Jose Pinzon del 29/05/2017
		--02349 Cristian Daniel Sanchez Restrepo
		--02252 Deby Maritza Chung Alie
		--02448 Dina M. Ortega de Quezada
		--02253 Leonardo Alfonso Chung Alie
		--02393 Sara Maria Dunn	   
	    if _cod_agente in ("01837","01569","01838","01315","01834","00623","01836","01575","01835","02201","02349","02252","02448","02253","02393") then  --- falta 02201 LATTY
		  let _cod_agente = "01048";
		end if	   
	   --  Afta Insurance Services(santiago)(02155), Asesora Tefi S.A.(00095), Ithiel Cesar Trib.(00130) , Seguros ICT, S.A(00235)
	    if _cod_agente in ("02155","00095","00130","00235") then	   --Cambio segun sol. 29/05/2014 por Leticia Escobar.
		  let _cod_agente = "01266";
		end if
		-- Solicitud de Leticia del 09/10/2013
		-- Unificar todos los KAM
		-- Demetrio Hurtado (02/10/2012)
		-- Se separa la unificacion por orden de leticia segun correo 12/04/2013, indica que se unen al final
		--"02082",se quita segun correo de Keyliam 19/07/2017
		if _cod_agente IN ('02528','02524','02525','02527','02526','00218',"02082","02360","02376","02293","02377","02378","02375","00133","01746","01749","01852","02004","02075","02124") then  
			let _cod_agente = "02523";													
		end if
		-- Solicitud de Leticia del 08/04/2013
		-- Unificar Noel Quintero y Joel Quintero
		-- Armando Moreno (08/04/2013)
		if _cod_agente = "01880" then
			let _cod_agente = "00395";													
		end if
		-- Solicitud de Leticia del 31/05/2013
		-- Unificar Tuesca & Asociados(00946) y Corporacion Comercial(00239)
		-- Armando Moreno (03/06/2013)
		if _cod_agente = "00239" then
			let _cod_agente = "00946";													
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar SEMUSA(00270) con semusa chitre y Semusa Santiago(01853,01814)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("01853","01814") then
			let _cod_agente = "00270";													
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar SSEGUROS NACIONALES(00125) con seguros nacionales david(02015)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("02015") then
			let _cod_agente = "00125";													
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar DUCRUET(00035) con ducruet david(02154)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("02154") then
			let _cod_agente = "00035";													
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar SEGUROS CENTRALIZADOS(00166) con seguro centralizados chiriqui(01745), seg. centr. chitre(01743), seg cent.colon(01744), seg. cent. santiago(01751)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("01745","01743","01744","01751","01851") then
			let _cod_agente = "00166";
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar SEGUROS TEMPUS(00474) con seg. tempus chitre(02081)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("02081") then
			let _cod_agente = "00474";
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar  lideres en seg. santiago(01990) con LIDERES EN SEGURO(01009)
 		-- Armando Moreno (29/09/2014)
		if _cod_agente in("01990") then
			let _cod_agente = "01009";
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar  B&G INSURANCE GROUP CHITRE(02103) con B&G INSURANCE GROUP(01670) 
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("02103") then
			let _cod_agente = "01670";
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar SH ASESORES DE SEGUROS(01898) con sh asesores de seg chorrera(02196)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("02196") then
			let _cod_agente = "01898";
		end if
		-- Solicitud de Leticia del 29/09/2014
		-- Unificar GONZALEZ DE LA GUARDIA Y ASOC.(00291) con maria e. de la guardia(00197)
		-- Armando Moreno (29/09/2014)
		if _cod_agente in("00197") then
			let _cod_agente = "00291";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Leysa Rodriguez(01904) Dalys de Rodriguez(00138) Mireya de Malo(01867) Sandra Caparroso(00965) con D.R. ASESORES DE SEGUROS(00011)
		if _cod_agente in("01904","00138","01867","00965") then
			let _cod_agente = "00011";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Daysi de la Rosa(01948) con Corredores de Seguros de la Rosa(02208)
		if _cod_agente in("01948") then
			let _cod_agente = "02208";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Asegure Corredor de Seguros(02102) con Lynette Lopez Arango(00817)
		if _cod_agente in("02102") then
			let _cod_agente = "00817";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Asegure Corredor de Seguros(00517) con J2L Asesores(01440)
		if _cod_agente in("00517") then
			let _cod_agente = "01440";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Hugo Caicedo (00525) con Blue Sea Insurance Brokers, Corp.(00779)
		if _cod_agente in("00525") then
			let _cod_agente = "00779";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Abdiel Teran Della Togna (00076) con Conjuga Insurance Solutions(02119)
		if _cod_agente in("00076","00937") then
			let _cod_agente = "02119";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Ureña y Ureña (00050) con Edgar Alberto Ureña Romero(00845)
		if _cod_agente in("00050") then
			let _cod_agente = "00845";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Seguros y Asesoria Maritima (01916) con Roderick Subia(00793)
		if _cod_agente in("01916") then
			let _cod_agente = "00793";
		end if
		-- Solicitud de Leticia del 20/02/2015
		-- Unificar Carlos Manuel Mendez (00104) Carlos Manuel Mendez Dutari (02037) con Marcha Seguros, S.A.(00119)
		if _cod_agente in("00104","02037") then
			let _cod_agente = "00119";
		end if
		-- Solicitud de Matilde Rosario del 24/02/2015
		-- Unificar Sandra Eckardt. (01779) con  ECKARDT seguros, s. a.(02229)
		if _cod_agente in("01779") then
			let _cod_agente = "02229";
		end if
		-- Solicitud de Gabriela G. correo de Yessi 24/05/2017
		-- UNIFIQUEN A LA CORREDORA DAYRA IRENE CHAVEZ CRUZ CODIGO 01504 AL CODIGO 02424 A D.C ASESORES DE SEGUROS
		if _cod_agente in("01504") then
			let _cod_agente = "02424";
		end if
		-- UNIFIQUEN A LA CORREDORA ANABEL QUINTERO VELASQUEZ CODIGO 01711 AL CODIGO 02134 PREVENZA 03/01/2018 correo Analisa
		if _cod_agente in("01711") then
			let _cod_agente = "02134";
		end if
		-- UNIFIQUEN A LA CORREDORA EDILDA MEDICA (PANAMA) CODIGO 02340 Y EDILDA MEDICA ( SANTIAGO) CODIGO 02086 AL CODIGO 01061 EDILDA MEDICA 03/01/2018 correo Analisa
		if _cod_agente in("02340","02086") then
			let _cod_agente = "01061";
		end if
		-- UNIFIQUEN A LA CORREDORA LINETTE FELICIA LOPEZ AROSEMENA CODIGO 00817 AL CODIGO 02230 SEGUROS LOPEZ ARANGO 03/01/2018 correo Analisa
		if _cod_agente in("00817") then
			let _cod_agente = "02230";
		end if
		-- UNIFIQUEN A LA CORREDORA IMARA DEL ROSARIO CODIGO 01992 AL CODIGO 01204 DEMPSIL DEL ROSARIO 30/01/2018 correo de Analisa
		if _cod_agente in("01992") then
			let _cod_agente = "01204";
		end if
end
return 0,_cod_agente;

END PROCEDURE