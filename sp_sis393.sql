-- Procedimiento para saber si debe llevar el endoso automatico o no.
-- Creado    : 10/10/2011 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis393;
CREATE PROCEDURE "informix".sp_sis393(a_poliza CHAR(10), a_ramo char(3)) 
RETURNING   integer; 

define _cantidad  integer;
define _error     integer;

SET ISOLATION TO DIRTY READ;

let _cantidad = 0;
let _error    = 0;


	 SELECT count(*)
	   INTO _cantidad
	   FROM emipouni
	  WHERE no_poliza       = a_poliza
	    and cont_beneficios = 1;

	 if _cantidad > 0 then
		let _error = sp_pro353("005",a_poliza,a_ramo);  --lleva endoso de Cont. de Cobertura
	 end if


	select count(*)
	  into _cantidad
	  from emiunire
	 where no_poliza = a_poliza;


	if _cantidad > 0 then
	 if _cantidad > 0 then
		let _error = sp_pro353("023",a_poliza,a_ramo);  --lleva endoso de Extra Prima
	 end if

	else
		select count(*)
		  into _cantidad
		  from emiderec
		 where no_poliza = a_poliza;

		 if _cantidad > 0 then
			 if _cantidad > 0 then
				let _error = sp_pro353("023",a_poliza,a_ramo);  --lleva endoso de Extra Prima
			 end if
		 end if
	end if


	select count(*)
	  into _cantidad
	  from emipreas
	 where no_poliza = a_poliza;

	if _cantidad > 0 then
		let _error = sp_pro353("006",a_poliza,a_ramo);  --lleva endoso de Exclusion
	else
		select count(*)
		  into _cantidad
		  from emiprede
		 where no_poliza = a_poliza;

		 if _cantidad > 0 then
			let _error = sp_pro353("006",a_poliza,a_ramo);  --lleva endoso de Exclusion
		 end if
	end if

return _error;

END PROCEDURE			   