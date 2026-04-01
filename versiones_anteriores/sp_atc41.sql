-- contratantes de Polizas Activas
-- Creado    : 09/03/2023 - Autor: HGIRON
-- SIS v.2.0 - - DEIVID, S.A.
DROP PROCEDURE sp_atc41;
CREATE PROCEDURE "informix".sp_atc41(a_cia CHAR(3), a_agencia CHAR(3), a_fecha date, a_tipo_persona CHAR(1))
returning VARCHAR(250) as Contratante;

DEFINE _tipo_persona     CHAR(1);
DEFINE v_descr_cia       CHAR(50);
DEFINE v_filtros         CHAR(255);
DEFINE _cod_contratante  CHAR(10); 
DEFINE _aseg_primer_nom  VARCHAR(60);
DEFINE _aseg_segundo_nom VARCHAR(60);
DEFINE _aseg_primer_ape  VARCHAR(60);
DEFINE _aseg_segundo_ape VARCHAR(60);
DEFINE _Contratante      VARCHAR(250);


--set debug file to "sp_atc41.trc";
--trace on;
drop table if exists tmp_Contratante;
	    CREATE TEMP TABLE tmp_Contratante(
              Contratante      CHAR(250))
              WITH NO LOG;


SET ISOLATION TO DIRTY READ;
LET v_descr_cia = sp_sis01(a_cia);
LET _aseg_primer_nom = NULL;
LET _aseg_segundo_nom = NULL;
LET _aseg_primer_ape = NULL;
LET _aseg_segundo_ape = NULL;
let _tipo_persona = '';

--polizas vigentes a la fecha
drop table if exists temp_perfil;
CALL sp_pro03(a_cia, a_agencia, a_fecha, '*') RETURNING v_filtros;

FOREACH
 SELECT distinct cod_contratante
   INTO _cod_contratante
   FROM temp_perfil
  WHERE seleccionado = 1


		SELECT distinct trim(aseg_primer_nom),
			   trim(aseg_segundo_nom),
			   trim(replace(upper(trim(aseg_primer_ape)),'Ñ','N')),   --aseg_primer_ape,
			   trim(replace(upper(trim(aseg_segundo_ape)),'Ñ','N')),   --aseg_segundo_ape,
			   trim(tipo_persona)
		  INTO _aseg_primer_nom,
			   _aseg_segundo_nom,
			   _aseg_primer_ape,
			   _aseg_segundo_ape,
			   _tipo_persona
		  FROM cliclien
		 WHERE cod_cliente = _cod_contratante;

		 if _tipo_persona not in ('N','J') then
		     continue foreach;
		 end if
		 if a_tipo_persona not in ('0') then
			 if _tipo_persona  <> a_tipo_persona then
				 continue foreach;
			 end if
		 end if

    if _aseg_primer_nom is null then
		LET _aseg_primer_nom = '';
	end if
    if _aseg_segundo_nom is null then
		LET _aseg_segundo_nom = '';
	end if
	    if _aseg_primer_ape is null then
		LET _aseg_primer_ape = '';
	end if
    if _aseg_segundo_ape is null then
		LET _aseg_segundo_ape = '';
	end if

	LET _aseg_primer_nom = UPPER(_aseg_primer_nom);
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"Á","A");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"É","E");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"Í","I");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"Ó","O");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"Ú","U");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,","," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,";"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"|"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"'"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"Ñ","N");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"!'"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"$"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"%"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"&"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"^"," ");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"'", "");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"Ã", "A");
	LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"."," ");
    LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"/"," ");
    LET _aseg_primer_nom = REPLACE(_aseg_primer_nom,"ñ","N");

	LET _aseg_segundo_nom = UPPER(_aseg_segundo_nom);
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"Á","A");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"É","E");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"Í","I");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"Ó","O");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"Ú","U");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,","," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,";"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"|"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"'"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"Ñ","N");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"!'"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"$"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"%"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"&"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"^"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"'", "");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"Ã", "A");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"."," ");
    LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"/"," ");
	LET _aseg_segundo_nom = REPLACE(_aseg_segundo_nom,"ñ","N");

	LET _aseg_primer_ape = UPPER(_aseg_primer_ape);
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"Á","A");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"É","E");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"Í","I");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"Ó","O");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"Ú","U");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,","," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,";"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"|"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"'"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"Ñ","N");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"!'"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"$"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"%"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"&"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"^"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"'", "");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"Ã", "A");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"."," ");
    LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"/"," ");
	LET _aseg_primer_ape = REPLACE(_aseg_primer_ape,"ñ","N");

	LET _aseg_segundo_ape = UPPER(_aseg_segundo_ape);
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"Á","A");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"É","E");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"Í","I");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"Ó","O");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"Ú","U");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,","," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,";"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"|"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"'"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"Ñ","N");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"!'"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"$"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"%"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"&"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"^"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"'", "");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"Ã", "A");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"."," ");
    LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"/"," ");
	LET _aseg_segundo_ape = REPLACE(_aseg_segundo_ape,"ñ","N");

	let _Contratante = trim(_aseg_primer_nom)||" "||trim(_aseg_segundo_nom)||" "||trim(_aseg_primer_ape)||" "||trim(_aseg_segundo_ape);
	if _Contratante is null then
	    continue foreach;
	end if

        if a_tipo_persona in ('N','J','0') then
			BEGIN
			ON EXCEPTION IN(-239,-268)
			END EXCEPTION
			insert into tmp_Contratante(
			Contratante)
			values(_Contratante);
			END
		end if


		--RETURN  _Contratante WITH RESUME;

END FOREACH

foreach
 select distinct Contratante
   into _Contratante
   from tmp_Contratante
  group by 1

RETURN  _Contratante WITH RESUME;

end foreach

DROP TABLE temp_perfil;
END PROCEDURE;