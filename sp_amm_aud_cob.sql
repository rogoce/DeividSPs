--------------------------------------------
---  REPORTE AUDITORIA INTERNA DE AUTOMOVIL
---  Armando Moreno M. 07/06/2022
--------------------------------------------

DROP procedure sp_amm_aud_cob;
CREATE procedure sp_amm_aud_cob()
RETURNING char(20),date,date,varchar(100),varchar(50),char(15),varchar(50),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2);

BEGIN

    DEFINE v_no_poliza                        CHAR(10);
    DEFINE v_no_documento                     CHAR(20);
    DEFINE v_vigencia_inic					  DATE;
    DEFINE v_vigencia_final					  DATE;
    DEFINE v_contratante                      CHAR(10);
    DEFINE v_no_unidad                        CHAR(5);
	DEFINE _cod_agente                        char(5);
	define _n_corredor						  varchar(50);
	DEFINE _cod_producto                      char(5);
	DEFINE v_producto                         varchar(50);
	define _estatus                           smallint;
	define _estatus_char                      char(15);
	define _n_asegurado                       varchar(100);
	define _saldo,_por_vencer,_corriente,_dias_30,_dias_60,_dias_90 dec(16,2);
	

SET ISOLATION TO DIRTY READ;

let _saldo      = 0;
let _por_vencer = 0;
let _corriente  = 0;
let _dias_30    = 0;
let _dias_60    = 0;
let _dias_90    = 0;
    
FOREACH WITH HOLD
	select no_documento,
           no_poliza,
		   saldo,
		   por_vencer,
		   corriente,
		   dias_30,
		   dias_60,
		   dias_90
	  into v_no_documento,
    	   v_no_poliza,
		   _saldo,
		   _por_vencer,
		   _corriente,
		   _dias_30,
		   _dias_60,
		   _dias_90
      from deivid_cob:cobmoros2
	 where periodo = '2022-05'
	   and no_documento[1,2] = '20'
	   and saldo_pxc <> 0

    select vigencia_inic,
	       vigencia_final,
		   cod_contratante,
		   estatus_poliza
	  into v_vigencia_inic,
	       v_vigencia_final,
           v_contratante,
		   _estatus
	  from emipomae
	 where no_poliza = v_no_poliza;

   foreach
	   SELECT cod_agente
		 INTO _cod_agente
		 FROM emipoagt
		WHERE no_poliza = v_no_poliza
	  exit foreach;
   end foreach

   select nombre
     into _n_corredor
	 from agtagent
	where cod_agente = _cod_agente;
	
   select nombre
     into _n_asegurado
	 from cliclien
	where cod_cliente = v_contratante;

   if _estatus = 1 then
		let _estatus_char = 'Vigente';
   elif _estatus = 2 then
		let _estatus_char = 'Cancelada';
   elif _estatus = 3 then
		let _estatus_char = 'Vencida';
   else
		let _estatus_char = 'Anulada';
   end if

   FOREACH 
	  SELECT no_unidad,
			 cod_producto
		INTO v_no_unidad,
			 _cod_producto
		FROM emipouni
	   WHERE no_poliza = v_no_poliza

	   SELECT nombre
		 INTO v_producto
		 FROM prdprod
		WHERE cod_producto = _cod_producto;
		
		return v_no_documento,v_vigencia_inic,v_vigencia_final,_n_asegurado,v_producto,_estatus_char,
               _n_corredor,_saldo,_por_vencer,_corriente,_dias_30,_dias_60,_dias_90 with resume;

   END FOREACH 
END FOREACH
END
END PROCEDURE;
