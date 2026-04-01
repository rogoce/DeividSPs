-- contratantes de Polizas Activas
-- Creado    : 09/03/2023 - Autor: HGIRON
-- Modifica  : 04/10/2023 HG SD#7955:JEPEREZ:Ajustar Generación del Reporte de Contratantes Activos

DROP PROCEDURE sp_atc43am;
CREATE PROCEDURE sp_atc43am(a_cia CHAR(3), a_agencia CHAR(3), a_fecha date, a_tipo_persona CHAR(1))
returning VARCHAR(250) as Contratante,
          char(30)     as cedula;

DEFINE _tipo_persona     CHAR(1);
DEFINE v_descr_cia       CHAR(50);
DEFINE v_filtros         CHAR(255);
DEFINE _cod_contratante  CHAR(10);
DEFINE _aseg_primer_nom  VARCHAR(60);
DEFINE _aseg_segundo_nom VARCHAR(60);
DEFINE _aseg_primer_ape  VARCHAR(60);
DEFINE _aseg_segundo_ape VARCHAR(60);
DEFINE _Contratante      VARCHAR(250);
DEFINE _Contratantef      VARCHAR(250);
define _cedula           char(30);

--set debug file to "sp_atc41.trc";

drop table if exists tmp_Contratante;
CREATE TEMP TABLE tmp_Contratante(
Contratante      CHAR(250),
cedula           char(30))
WITH NO LOG;
create index i_tmp_Contr1 on tmp_Contratante(contratante);


SET ISOLATION TO DIRTY READ;
LET v_descr_cia = sp_sis01(a_cia);
LET _aseg_primer_nom = NULL;
LET _aseg_segundo_nom = NULL;
LET _aseg_primer_ape = NULL;
LET _aseg_segundo_ape = NULL;
let _tipo_persona = '';

--polizas vigentes a la fecha
drop table if exists temp_perfil;
--CALL sp_pro03(a_cia, a_agencia, a_fecha, '*') RETURNING v_filtros;

{FOREACH
	SELECT distinct cod_contratante
	  INTO _cod_contratante
	  FROM temp_perfil
	 WHERE seleccionado = 1}
--trace on;
	let  _cod_contratante = '403722';


	SELECT distinct trim(aseg_primer_nom),
		   trim(aseg_segundo_nom),
		   trim(replace(upper(trim(aseg_primer_ape)),"T","Z")),
		   trim(replace(upper(trim(aseg_segundo_ape)),"Ñ","N")),
		   trim(tipo_persona),
		   trim(cedula)
	  INTO _aseg_primer_nom,
		   _aseg_segundo_nom,
		   _aseg_primer_ape,
		   _aseg_segundo_ape,
		   _tipo_persona,
		   _cedula
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;
	 
	--let _aseg_primer_ape = trim(replace(_aseg_primer_ape,"Ñ","N"));
	
	RETURN  _aseg_primer_ape,_cedula;
--trace on;	

	if _tipo_persona not in ('N','J') then
		--continue foreach;
	end if
	if a_tipo_persona not in ('0') then
		if _tipo_persona  <> a_tipo_persona then
			--continue foreach;
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
	LET _aseg_segundo_nom = UPPER(_aseg_segundo_nom);
	LET _aseg_primer_ape = UPPER(_aseg_primer_ape);	
	LET _aseg_segundo_ape = UPPER(_aseg_segundo_ape);
	--trace on;
	let _Contratante = trim(_aseg_primer_nom)||" "||trim(_aseg_segundo_nom)||" "||trim(_aseg_primer_ape)||" "||trim(_aseg_segundo_ape);
	
	if _Contratante is null then
	    --continue foreach;
	end if

	if a_tipo_persona in ('N','J','0') then
		let _contratantef = '';
		let _Contratante = rtrim(_Contratante);	
		let _Contratante = ltrim(_Contratante);				
		call sp_atc41a(_Contratante) returning _contratantef;			
		if _Contratantef is null or trim(_Contratantef) = '' then
			--continue foreach;
		end if			
		BEGIN
		ON EXCEPTION IN(-239,-268)
		END EXCEPTION
		insert into tmp_Contratante(
		Contratante,cedula)
		values(_Contratantef,_cedula);
		END
	end if

--END FOREACH

foreach
 select distinct Contratante,
        cedula
   into _Contratante,
        _cedula
   from tmp_Contratante
  group by 1,2

RETURN  _Contratante,_cedula WITH RESUME;

end foreach

--DROP TABLE temp_perfil;
END PROCEDURE

