-- Procedimiento para verificar descuento de pronto pago al cancelar polizas
--
-- Creado    : 27/12/2012 - Autor: Federico Coronado
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_imp07;
CREATE PROCEDURE sp_imp07(a_poliza CHAR(10), a_cod_endomov CHAR(3), a_cod_endomov1 char(3))
			RETURNING   integer,	--v_
						char(100);	--v_mensaje

						define _pronpag integer;
						define _reverpag integer;
						define _mensaje char(100);
						
SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_imp07.trc";      
--TRACE ON;                                                    

let _mensaje = "";
let _pronpag = "";
let _reverpag = "";

    if a_poliza in('1745327','1650866','1692857','1603021','2007671') then
		return 0, _mensaje;
	end if

	select count(*)
	  into _pronpag
	  from endedmae 
	 where no_poliza   = a_poliza
	   and cod_endomov = a_cod_endomov
	   and actualizado = 1;

		if _pronpag > 0 then
			select count(*)
			  into _reverpag
			  from endedmae 
			 where no_poliza   = a_poliza
			   and cod_endomov = a_cod_endomov1
			   and actualizado = 1;
		end if
		
	if _pronpag <> _reverpag then
		let _mensaje = "Esta póliza tiene descuento de pronto pago. Para Cancelar se debe reversar el mísmo, por favor verifique";
		RETURN 1, _mensaje;
	else 
		return 0, _mensaje;
    end if 
	
END PROCEDURE