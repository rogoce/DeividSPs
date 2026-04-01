--Consecutivo de polizas - Auditoria
--05/03/2013	Armando Moreno M.

DROP procedure sp_leyri08;
CREATE procedure "informix".sp_leyri08(a_fecha1 date, a_fecha2 date)
RETURNING CHAR(3),CHAR(50),CHAR(20),char(50),DEC(16,2),DEC(16,2),date,char(3),char(25);

   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_suma_asegurada   DECIMAL(16,2);
      DEFINE v_comision                      DECIMAL(9,2);
      DEFINE v_desc_nombre                   CHAR(50);
      DEFINE v_desc_ramo                     CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(1);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago                    CHAR(3);
      DEFINE v_cant_pagos                    SMALLINT;
      DEFINE v_descr_cia,v_desc_agente       CHAR(50);
	  define v_cod_agente					 char(5);
	  define v_nueva_renov					 char(1);
	  define v_nomuser						 varchar(50);
	  define _user							 varchar(15);
	  define _desc_endoso					 char(6);
	  define v_sucursal						 char(50);
	  define _desc_nueva_renov				 char(12);
	  define _fecha_impresion				 date;
	  define _fecha_emision					 date;
	  define _nom_agente					 varchar(50);
	  define _no_poliza                      char(10);
	  define _renonueva						 char(25);

      SET ISOLATION TO DIRTY READ;

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;

foreach

	 select distinct no_documento,no_poliza, nueva_renov,cod_sucursal
	   into v_nodocumento,_no_poliza,v_nueva_renov,v_sucursal
	   from emipomae
	  where actualizado = 1
		and nueva_renov in('N','R')
	    and fecha_suscripcion >= a_fecha1
		and fecha_suscripcion <= a_fecha2

         SELECT cod_ramo,
         		cod_contratante,
                suma_asegurada,
				fecha_suscripcion
           INTO v_cod_ramo,
           		v_cod_contratante,
                v_suma_asegurada,
				_fecha_emision
           FROM emipomae
          WHERE actualizado = 1
		    AND no_poliza = _no_poliza;

         select sum(prima_suscrita)
		   into	v_prima_suscrita
		   from endedmae
		  where no_poliza = _no_poliza
		    and actualizado = 1;
        
         SELECT nombre
           INTO v_desc_ramo
           FROM prdramo
          WHERE cod_ramo = v_cod_ramo;

         SELECT nombre
           INTO v_desc_nombre
           FROM cliclien
          WHERE cod_cliente = v_cod_contratante;
		  
		  IF v_nueva_renov = 'N' THEN
			LET _renonueva = 'NUEVA';
		  END IF
		  IF v_nueva_renov = 'R' THEN
			LET _renonueva = 'RENOVADA';
		  END IF

         RETURN v_cod_ramo,v_desc_ramo,v_nodocumento,v_desc_nombre,v_suma_asegurada,v_prima_suscrita,
                _fecha_emision,v_sucursal, _renonueva WITH RESUME;


end foreach
END
END PROCEDURE;







												