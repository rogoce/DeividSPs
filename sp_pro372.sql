--- ****Renovacion Automatica. Proceso de excepciones ****
--- Creado 02/03/2009 por Armando Moreno
--- Modificado 17/06/2009 por Henry

drop procedure sp_pro372;
create procedure "informix".sp_pro372(a_no_poliza char(10))
returning integer,char(100);

define _error_desc			char(100);
define _no_documento		char(21);
define _usuario				char(8);
define _centro_costo		char(3);
define _cod_ramo			char(3);
define _cnt_emiredes_sis	smallint;
define _cnt_emirepol		smallint;
define _cnt_emideren		smallint;
define _sis_renglon			smallint;
define _cnt_emirepo			smallint;
define _jerarquia       	smallint;
define _cnt					smallint;
define _error_isam			integer;
define _error				integer;

on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc;
end exception

select no_documento,
	   cod_ramo
  into _no_documento,
	   _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;
 
select count(*)
  into _cnt
  from eminotas
 where no_documento = _no_documento
   and procesado = 0;

select count(*)
  into _cnt_emirepo
  from emirepo
 where no_poliza = a_no_poliza;

select count(*)
  into _cnt_emirepol
  from emirepol
 where no_poliza = a_no_poliza;
 
select count(*)
  into _cnt_emideren
  from emideren
 where no_poliza = a_no_poliza;
 
if _cod_ramo <> '020' then
	if _cod_ramo in("001","003","010","011") then
		let _usuario = sp_pro322(_centro_costo,'5',51);
		let _jerarquia = sp_pro327(_centro_costo,'5',51,_usuario);
		let _sis_renglon = 51;
	elif _cod_ramo in("005","006","007","009","015","004","017") then
		let _usuario = sp_pro322(_centro_costo,'5',52);
		let _jerarquia = sp_pro327(_centro_costo,'5',52,_usuario);
		let _sis_renglon = 52;
	else
		let _usuario = sp_pro322(_centro_costo,'5',12);
		let _jerarquia = sp_pro327(_centro_costo,'5',12,_usuario);
		let _sis_renglon = 12;
	end if
	if _cnt_emideren > 0 then
	end if
	
	insert into tmp_reaut(usuario,no_poliza,renglon,tipo_ramo) values (_usuario,a_no_poliza,_sis_renglon,'5');
	insert into emideren(no_poliza,renglon) values (v_poliza,_renglon);
end if

end procedure