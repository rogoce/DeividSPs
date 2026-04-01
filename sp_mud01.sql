-- POLIZAS VIGENTES solo Automovil y soda
-- Creado    : 23/04/2014 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro32('001','001','16/08/2012',"*","*","*","*","*","39852;","*","*")

   DROP procedure sp_mud01;
   CREATE procedure "informix".sp_mud01(a_cia CHAR(03),a_fecha DATE)

   RETURNING CHAR(20),varchar(50),varchar(30),date, date, varchar(50), varchar(10),varchar(30),varchar(30),varchar(5),varchar(30),varchar(30),varchar(30),dec(16,2);

    DEFINE v_descr_cia                                CHAR(50);
    DEFINE _no_documento               			      CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final           DATE;
    DEFINE v_suma_asegurada   	                      DECIMAL(16,2);
	DEFINE v_poliza                                   char(10);
	DEFINE v_cod_contratante                          char(10);
	DEFINE v_cod_producto,v_no_unidad                 char(10);
	define _nombre_cliente                            varchar(50);
	define _cedula                                    varchar(30);
    define _no_motor                                  varchar(30);
	define _cod_modelo                                varchar(10);   
	define _cod_marca                                 varchar(10);
	define _placa                                     varchar(10);
	define _ano_auto                                  integer;
	define _chasis                                    varchar(30);
	define _nombre_marca, _nombre_modelo, nombre_plan varchar(50);

    SET ISOLATION TO DIRTY READ;

    LET v_descr_cia = sp_sis01(a_cia);
   --ramo Auto y soda
   foreach
     SELECT d.no_poliza, 
			d.no_documento, 
			d.cod_contratante, 
			vigencia_inic,
			vigencia_final
	   into v_poliza, 
	        _no_documento, 
		    v_cod_contratante, 
		    v_vigencia_inic, 
		    v_vigencia_final
	   FROM emipomae d
      WHERE d.cod_compania    = a_cia
	    AND d.actualizado = 1
        AND estatus_poliza = 1
        AND cod_ramo in('002','020')
        AND (d.vigencia_final   >= a_fecha OR d.vigencia_final IS NULL)
        AND d.fecha_suscripcion <= a_fecha
        AND d.vigencia_inic     <= a_fecha
      order by no_documento

	   FOREACH
			select cod_producto, no_unidad, suma_asegurada
			  INTO v_cod_producto, v_no_unidad, v_suma_asegurada
			  from emipouni
			 where no_poliza = v_poliza
			
			select cedula, nombre
			  into _cedula,
				   _nombre_cliente
			from cliclien
			where cod_cliente = v_cod_contratante;
			
			select no_motor
			  into _no_motor
			  from emiauto
			 where no_poliza = v_poliza
			  and no_unidad = v_no_unidad;
			  
			select cod_modelo, 
			       cod_marca,  
				   placa,
				   ano_auto,
				   no_chasis
			  into _cod_modelo,
			       _cod_marca,
				   _placa, 
				   _ano_auto,
				   _chasis
			from emivehic
			where no_motor = _no_motor;
			
			select nombre
			  into _nombre_marca
			  from emimarca
			 where cod_marca = _cod_marca; 
			 
			select nombre
			  into _nombre_modelo
			  from emimodel
			 where cod_modelo = _cod_modelo; 
			 
			 select nombre
			   into nombre_plan
			   from prdprod
			  where cod_producto = v_cod_producto;
			
       RETURN  _no_documento, 
	           _nombre_cliente, 
			   _cedula, 
			   v_vigencia_inic, 
			   v_vigencia_final,
			   nombre_plan, 
			   v_no_unidad,
 			   _nombre_marca,
			   _nombre_modelo,
			   _placa, 
			   _ano_auto,
			   _no_motor,
			   _chasis,
			   v_suma_asegurada WITH RESUME;
		END FOREACH
	end foreach
END PROCEDURE;
