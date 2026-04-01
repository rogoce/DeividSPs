--Procedimiento para saber si la póliza aplica o no para el pago por:
--Cancelada o Anulada
--Vigente y Motivo de No Renovación -039 Cese de Coberturas(Ley 12)
--Creado por: AMM 03/06/2025


DROP PROCEDURE sp_sis519a;
CREATE PROCEDURE sp_sis519a(a_no_documento CHAR(20), a_opc smallint default 0)
RETURNING CHAR(10);

define _cod_no_renov,_cod_formapag    char(3);
define _no_poliza       			  char(10);
define _estatus_poliza,_cnt           smallint;
define _cod_grupo                     char(5);

SET ISOLATION TO DIRTY READ;

select no_poliza
  into _no_poliza
  from emipoliza
 where no_documento = a_no_documento;

select estatus_poliza,
	   cod_no_renov,
	   cod_formapag,
	   cod_grupo
  into _estatus_poliza,
	   _cod_no_renov,
	   _cod_formapag,
	   _cod_grupo
  from emipomae
 where no_poliza = _no_poliza;
 
 --SD16320
 select count(*)
   into _cnt
   from emipoagt
  where no_poliza = _no_poliza
    and cod_agente in('03205','03250','00035','02154','02656','02904');
	
if _no_poliza is null then
	let _cnt = 0;
end if
if _cnt > 0 then
	return 0;
end if
 
--excepciones Forma de Pago
--085 – FRO - FRONTING
--091 – GOB – GOBIERNO

if _cod_formapag in('085','091') then
	return 0;
end if
--excepciones Grupo
if _cod_grupo in('00096','00953','1009','1024','1050','1078','1090','1122','124','125','148','77787','77850','77960','77973','77974','77982','78015','78020','78022') then
	return 0;
end if

----excepciones Polizas con contrato facultativo
select count(*)
  into _cnt
 from emifacon r, reacomae t
where r.cod_contrato = t.cod_contrato
  and r.no_poliza = _no_poliza
  and r.no_endoso = '00000'
  and t.tipo_contrato = 3;
  
if _cnt is null then
	let _cnt = 0;
end if  
if _cnt > 0 then
	return 0;
end if

if a_opc = 0 then --Verifica todas las condiciones
	if _estatus_poliza in(2) then
		return 1; -- cancelada
	end if
	if _estatus_poliza in(4) then
		return 3; -- anulada
	end if
	if _estatus_poliza = 1 AND _cod_no_renov = '039' then
		return 2; -- Cesada;
	end if
end if
RETURN 0;

END PROCEDURE
                                                                                                                                                                                    