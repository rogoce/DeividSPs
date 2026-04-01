-- Procedimiento que Busca el Acreedor de una Poliza con Reclamo

-- Creado    : 16/09/2004 - Autor: Amado Perez M.
-- Modificado: 16/09/2004 - Autor: Amado Perez M.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

--DROP PROCEDURE sp_rec100;

CREATE PROCEDURE sp_rec100(a_no_reclamo	char(10))
returning char(100);

define v_acreedor		char(100);
define _no_poliza		char(10);
define _no_unidad       char(5);
define _cod_acreedor    char(5);
define _fecha_siniestro date;
define _fecha_emision	date;
define _cant            smallint;

SET ISOLATION TO DIRTY READ;



foreach
	select no_poliza,
		   no_unidad,
		   fecha_siniestro
	  into _no_poliza,
	  	   _no_unidad,
		   _fecha_siniestro
	  from recrcmae
	 where no_reclamo = a_no_reclamo

	let _cod_acreedor = Null;

	   
    foreach
		select cod_acreedor
		  into _cod_acreedor
		  from emipoacr
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		 exit foreach;
	end foreach

    If _cod_acreedor Is Null Or trim(_cod_acreedor) = "" Then	  --> si se borro la unidad la busco de endoso Amado 4/8/2010 segun Caso 08585 del helpdesk
	   let _cant = 0;
	   select count(*) 
	     into _cant
		 from emipouni
		where no_poliza = _no_poliza
		  and no_unidad = _no_unidad;

        if _cant = 0 then
		    foreach
				select cod_acreedor
				  into _cod_acreedor
				  from endedacr
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				order by no_endoso desc
				 exit foreach;
			end foreach
		end if

    	If _cod_acreedor Is Null Or trim(_cod_acreedor) = "" Then
			Return "";
		Else
	        select nombre 
			  into v_acreedor
			  from emiacre
			 where cod_acreedor = _cod_acreedor;

	        Return v_acreedor;
		End If
	Else 
        select nombre 
		  into v_acreedor
		  from emiacre
		 where cod_acreedor = _cod_acreedor;

        Return v_acreedor;
	End If

end foreach

END PROCEDURE
