

DROP PROCEDURE sp_sis165;
--Armando Moreno 29/12/2011

CREATE PROCEDURE "informix".sp_sis165(a_cod_contratante CHAR(10))
RETURNING INTEGER;

define _cnt          smallint;
define a_no_poliza   char(10);

SET ISOLATION TO DIRTY READ;

let _cnt = 0;

BEGIN

	select count(*)
	  into _cnt
	  from emipomae
	 where actualizado     = 1
	   and cod_contratante = a_cod_contratante
	   and cod_ramo        = '020'
	   and estatus_poliza  = 3;  --vencida

	if _cnt > 0 then

		foreach

			select no_poliza
			  into a_no_poliza
			  from emipomae
			 where actualizado = 1
			   and cod_contratante = a_cod_contratante
			   and cod_ramo        = '020'
			   and estatus_poliza  = 3

			select count(*)
			  into _cnt
			  from recrcmae
			 where no_poliza       = a_no_poliza
			   and estatus_reclamo = "A"
			   and actualizado     = 1;

			if _cnt > 0 then
				exit foreach;
			end if

		end foreach

	end if

	if _cnt > 0 then --Tiene Reclamo Abierto

		return 1;

    end if

RETURN 0;

END

END PROCEDURE;
