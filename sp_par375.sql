-- Dif comision por ramo
--  
-- Creado    : 05/07/2021 - Autor: Amado Perez

DROP PROCEDURE sp_par375;
CREATE PROCEDURE sp_par375(a_periodo char(7)) 
RETURNING  CHAR(10) as no_poliza,
           CHAR(5)  as no_endoso,
		   CHAR(10) as no_factura,
		   CHAR(20) as no_documento,
		   DEC(16,2) as com_prod,
		   DEC(16,2) as mayor;
 
DEFINE _no_poliza			CHAR(10);
DEFINE _no_endoso			CHAR(5);
DEFINE _no_factura  		CHAR(10);
DEFINE _no_documento		CHAR(20);
DEFINE _comision			DEC(16,2);
DEFINE _mayor       		DEC(16,2);
DEFINE _porc_partic_agt		DEC(5,2);
DEFINE _cnt         		SMALLINT;
 

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_eco03.trc";	
 -- trace on;

FOREACH
	select a.no_poliza,
		   a.no_endoso,
		   a.no_factura,
		   a.no_documento,
		   sum(b.porc_partic_agt),
		   sum(a.prima_suscrita * (b.porc_partic_agt / 100) * (b.porc_comis_agt / 100))
	  into _no_poliza,
           _no_endoso,
           _no_factura,
           _no_documento,
           _porc_partic_agt,
           _comision		   
	  from endedmae a, endmoage b
	 where a.no_poliza = b.no_poliza
	   and a.no_endoso = b.no_endoso
	   and a.periodo     = a_periodo
	   and a.prima_suscrita <> 0
	   and b.porc_comis_agt <> 0
	   and a.actualizado  = 1
	   group by  a.no_poliza, a.no_endoso, a.no_factura, a.no_documento
	 order by a.no_poliza, a.no_endoso
	 
	select count(*)
	  into _cnt
	  from endasien
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and cuenta[1,3] = "521"
	   and periodo = a_periodo;
	   
	if _cnt = 0 then
			return _no_poliza,
                   _no_endoso,
                   _no_factura,
                   _no_documento,
                   _comision,
				   0
				   WITH RESUME;
    else
		select debito + credito
		  into _mayor
		  from endasien
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and cuenta[1,3] = "521"
		   and periodo = a_periodo;
		   
		if ABS(_comision - _mayor) > 1 THEN
			return _no_poliza,
                   _no_endoso,
                   _no_factura,
                   _no_documento,
                   _comision,
				   _mayor
				   WITH RESUME;
        end if	
    end if		
END FOREACH
END PROCEDURE	  