-- Retorna los Reclamos de una Poliza
-- 
-- Creado    : 26/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 26/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis429;
create procedure sp_sis429(a_no_motor char(30), a_cod_modelo char(5))
returning integer;

define _no_unidad		  char(10);
define _no_poliza		  char(10);
define _cod_modelo        char(5);
define _actualizado       smallint;
define _flag              smallint;


set isolation to dirty read;

let _flag = 0;
foreach

	select no_poliza,
	       no_unidad
	  into _no_poliza,
	       _no_unidad
	  from emiauto
     where no_motor = a_no_motor

    select actualizado
      into _actualizado
      from emipomae
     where no_poliza = _no_poliza;

    if _actualizado = 1 then
		continue foreach;
	else
		select cod_modelo
		  into _cod_modelo
		  from emivehic
		 where no_motor = a_no_motor;
		 if a_cod_modelo = '' or a_cod_modelo is null then
			continue foreach;
		 end if
		if _cod_modelo <> a_cod_modelo then
			delete from emipocob
			where no_poliza = _no_poliza
			  and no_unidad = _no_unidad;
			  
			delete from emifacon
			where no_poliza = _no_poliza
			  and no_unidad = _no_unidad
			  and no_endoso = '00000';
			let _flag = 1;
		end if
		 
	end if	

end foreach

return _flag;		
end procedure