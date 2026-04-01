-- Procedimiento que verifica si la póliza aplica para los proceso de nulidad o suspensión de cobertura.
-- Creado: 17/10/2017 - Autor: Román Gordón
-- Por el momento las excepiones de los procesos de suspensión de cobertura y nulidad de póliza son los mismos. 
-- En caso de que las excepiones cambien entonces se debe manejar con el parametro a_proceso 1= Nulidad, 2= Suspensión
-- execute procedure(sp_ley003('0217-00252-03',1)
-- Modificado: 18/05/2020 - Autor: Henry Girón  caso#34638 El Ramo(004)/Subramo ESCOLARES no aplica
drop procedure sp_ley003;
create procedure sp_ley003(a_no_documento char(20),a_proceso smallint)
returning	smallint		as cod_error,
			varchar(100)	as mensaje;

define _mensaje				varchar(100);
define _no_poliza			char(10);
define _cod_grupo			char(5);
define _cod_formapag		char(3);
define _cod_tipoprod		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _tipo_produccion		smallint;
define _estatus_poliza		smallint;
define _fronting			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_suspension	date;

set isolation to dirty read;

--set debug file to "sp_ley003.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
	return _error,_mensaje;
end exception

let _no_poliza = sp_sis21(a_no_documento);

select cod_ramo,
	   cod_subramo,
	   cod_formapag,
	   estatus_poliza,
	   fronting,
	   cod_grupo,
	   cod_tipoprod
  into _cod_ramo,
	   _cod_subramo,
	   _cod_formapag,
	   _estatus_poliza,
	   _fronting,
	   _cod_grupo,
	   _cod_tipoprod
  from emipomae
 where no_poliza = _no_poliza;

if _estatus_poliza not in (1,3) then
	return 1,'Solo Aplican Pólizas Vigentes';
end if

if _cod_ramo in ('008','014') then --'004','016','018','019') Se elimina ramos personales de la exclusión 19/01/2016
	return 1,'El Ramo/Subramo no aplica';
elif _cod_ramo in ('016') and _cod_subramo in ('007') then --Colectivo de Vida, Subramo Desgravamen
	return 1,'El Ramo/Subramo no aplica';
end if

if _cod_formapag in ('084','085','091') then
	return 1,'La Forma de Pago no aplica';
end if

if _fronting = 1 then
	return 1,'Fronting no aplica';
end if	

--se quita grupo 162 F9 Jean Carlos 10/06/2019  --SD#6078 ,'148'
if _cod_grupo in ('00000','1000','1090','1009','01016','124','00087','125','1122','00087','77960','77982','77850','78020','78033',
                  '78032','78034') then --grupos del Estado, SCOTIA BANK y BAGATRAC,Se agrega a Liszenell Bernal Banisi 26/02/2018 8:46 am Ducruet 15/01/2019 CASO: 30140 USER: ASTANZIO   -- SD#5708 23/02/2023 HG
	return 1,'El Grupo no aplica';   --CASO: 30140 USER: ASTANZIO grupo: 148  desde: 18/12/2018 5pm  --CASO: 31333 USER: ASTANZIO 5/5/2019 00087 Excluir   SD#3010 07/04/2022 4:00pm
end if

select tipo_produccion
  into _tipo_produccion
  from emitipro
 where cod_tipoprod = _cod_tipoprod;

if _tipo_produccion in (3,4) then
	return 1,'El Tipo de Producción no aplica';
end if

-- CASO: 35776 USER: RGORDON ASUNTO:SE ELIMINA LA EXCEPCION SEGUN DRN 34638 -- Amado Perez 12-10-2020
{
if a_proceso = 1 then
    -- CASO: 34638 USER: JEPEREZ PC: CMORGA25 Problema:EXCEPCIONAR DEL PROCESO DIARIO DE NULIDAD AUTOMÁTICA LAS PÓLIZAS DEL RAMO ACCIDENTES PERSONALES (004), SUBRAMOS ESCOLARES 2 (006) Y ESCOLARES 1 (007)
	if (_cod_ramo in ('004') and _cod_subramo in ('006')) or (_cod_ramo in ('004') and _cod_subramo in ('007')) then --Colectivo de Vida, Subramo Desgravamen
	   return 1,'El Ramo(004)/Subramo ESCOLARES no aplica';	   
    end if
end if
}

return 0,'Aplica';

end
end procedure;