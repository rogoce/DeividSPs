--Consecutivo de reclamos - Auditoria
--15/03/2013	Armando Moreno M.

DROP procedure sp_leyri09;
CREATE procedure "informix".sp_leyri09(a_fecha1 date, a_fecha2 date)
RETURNING CHAR(18),CHAR(20),CHAR(50),char(50),date,DEC(16,2),char(1);

   BEGIN
      DEFINE v_nopoliza,_no_reclamo          CHAR(10);
	  DEFINE v_numrecla						 CHAR(18);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE _fecha_siniestro                date;
      DEFINE v_cod_ramo 					 CHAR(03);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_desc_nombre                   CHAR(50);
      DEFINE v_desc_ramo                     CHAR(50);
	  define _no_poliza                      char(10);
	  define _pagado                         char(1);
	  define _pagos							 DECIMAL(16,2);

      SET ISOLATION TO DIRTY READ;

      LET _pagos            = 0;
      LET v_cod_contratante = NULL;

foreach

	 select numrecla,
	        no_poliza,
			fecha_siniestro,
			no_reclamo
	   into v_numrecla,
	   		_no_poliza,
			_fecha_siniestro,
			_no_reclamo
	   from recrcmae
	  where actualizado = 1
	    and fecha_reclamo >= a_fecha1
		and fecha_reclamo <= a_fecha2
	  order by numrecla

         SELECT sum(pagos)
           INTO _pagos
           FROM recrccob
          WHERE no_reclamo = _no_reclamo;

		 if abs(_pagos) > 0 then
			let _pagado = '*';
		 else
			let _pagado = '';
		 end if

         SELECT cod_ramo,
         		cod_contratante,
				no_documento
           INTO v_cod_ramo,
           		v_cod_contratante,
				v_nodocumento
           FROM emipomae
          WHERE actualizado = 1
		    AND no_poliza = _no_poliza;
        
         SELECT nombre
           INTO v_desc_ramo
           FROM prdramo
          WHERE cod_ramo = v_cod_ramo;

         SELECT nombre
           INTO v_desc_nombre
           FROM cliclien
          WHERE cod_cliente = v_cod_contratante;

         RETURN v_numrecla,v_nodocumento,v_desc_ramo,v_desc_nombre,_fecha_siniestro,_pagos,_pagado WITH RESUME;


end foreach
END
END PROCEDURE;







												