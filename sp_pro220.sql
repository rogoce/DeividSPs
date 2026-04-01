-- Procedimiento que Unifica las Marcas	y modelos
-- 
-- Creado    : 24/05/2012 - Autor: Armando Moreno M.
-- Modificado: 24/05/2012 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro220;
create procedure "informix".sp_pro220(a_cod_marca_queda char(5), a_cod_marca_eli char(5), a_parametro integer default 0, a_user char(8))
       returning	    int,char(50);


define _error			 integer;
define _error_isam		 integer;
define _error_desc		 char(50);
define _fecha            date;

SET ISOLATION TO DIRTY READ;


begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _fecha = current;

if a_parametro = 0 then --marcas

	update recterce
	   set cod_marca = a_cod_marca_queda
	 where cod_marca = a_cod_marca_eli;

	update cfsducma
	   set cod_marca = a_cod_marca_queda
	 where cod_marca = a_cod_marca_eli;

	update emivehic
	   set cod_marca = a_cod_marca_queda
	 where cod_marca = a_cod_marca_eli;

	update equimarca
	   set cod_marca_ancon = a_cod_marca_queda
	 where cod_marca_ancon = a_cod_marca_eli;

	update equimodel
	   set cod_marca_ancon = a_cod_marca_queda
	 where cod_marca_ancon = a_cod_marca_eli;

	select * 
	  from emimodel
	 where cod_marca = a_cod_marca_eli
	  into temp prueba;

	insert into emimodelbi	--bitacora de modelos
	select * 
	  from prueba;

	drop table prueba;

	update emimodel
	   set cod_marca = a_cod_marca_queda
	 where cod_marca = a_cod_marca_eli;

	delete from emimarca
	 where cod_marca = a_cod_marca_eli;

	insert into emimarcabi(
			cod_marca_queda,
			cod_marca_eli,
			user_added,
			date_added)
	values(	a_cod_marca_queda,
			a_cod_marca_eli,
			a_user,
			_fecha);
else

	update recterce
	   set cod_modelo = a_cod_marca_queda
	 where cod_modelo = a_cod_marca_eli;

	update cfsducma
	   set cod_modelo = a_cod_marca_queda
	 where cod_modelo = a_cod_marca_eli;

	update emivehic
	   set cod_modelo = a_cod_marca_queda
	 where cod_modelo = a_cod_marca_eli;

	update equimodel
	   set cod_modelo_ancon = a_cod_marca_queda
	 where cod_modelo_ancon = a_cod_marca_eli;

	update prdemielctdet
	   set cod_modelo = a_cod_marca_queda
	 where cod_modelo = a_cod_marca_eli;

	update emimodelver
	   set cod_modelo = a_cod_marca_queda
	 where cod_modelo = a_cod_marca_eli;

	delete from emimodel
	where cod_modelo = a_cod_marca_eli;

	insert into modeldepur(
			cod_modelo_queda,
			cod_modelo_eli,
			user_added,
			date_added)
	values(	a_cod_marca_queda,
			a_cod_marca_eli,
			a_user,
			_fecha);
end if
end

return 0,"Unificacion Exitosa...";

end procedure 