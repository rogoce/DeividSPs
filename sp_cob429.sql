-- CARTERA DE FORMA DE PAGO CONSUMO (ANC) MOROSIDAD 30 DIAS
-- 
-- Creado    : 14/01/2023 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob429;

CREATE PROCEDURE "informix".sp_cob429() 
	   RETURNING CHAR(20) as Poliza,
	             CHAR(5) as Unidad,
				 DATE as Vigencia_Inicial,
				 DATE as Vigencia_Final,
				 CHAR(10) as Cod_Contratante,
				 CHAR(100) as Contratante,
				 CHAR(10) as Cod_Asegurado,
				 CHAR(100) as Asegurado,
				 CHAR(5) as Cod_Producto,
				 CHAR(50) as Producto,
				 CHAR(5) as Cod_Grupo,
				 CHAR(50) as Grupo;
				 

DEFINE v_no_poliza       CHAR(10);
DEFINE v_no_documento    CHAR(20);
DEFINE _cod_grupo        CHAR(5);
DEFINE _cod_contratante  CHAR(10);
DEFINE _serie            SMALLINT;
DEFINE _cnt_rec          SMALLINT;
DEFINE _no_unidad        CHAR(5);
DEFINE _no_motor         CHAR(30);
DEFINE _ano_auto         SMALLINT;
DEFINE _cod_producto     CHAR(5);
DEFINE _vigencia_inic    DATE;
DEFINE _vigencia_final   DATE;
DEFINE _cod_asegurado    CHAR(10);
DEFINE _contratante      CHAR(100);
DEFINE _asegurado        CHAR(100);
DEFINE _producto         CHAR(50);
DEFINE _grupo            CHAR(50);
DEFINE _moro             DEC(16,2);

SET ISOLATION TO DIRTY READ;

FOREACH
 -- Lectura de Polizas
	select distinct a.no_poliza,
	       a.no_documento,
		   a.cod_grupo,
		   a.cod_contratante
	  into v_no_poliza,
	       v_no_documento,
		   _cod_grupo,
		   _cod_contratante
	  from emipomae a
	 where a.cod_ramo = '002'
	   and a.cod_subramo = '001'
	   and a.estatus_poliza = 1
	   and a.actualizado = 1
	   and a.cod_formapag = '006'
	   
	let _moro = 0;   

    select sum(dias_60 + dias_90) 
	  into _moro
	  from deivid_cob:cobmoros2 
	 where no_documento = v_no_documento
       and periodo >= '2022-01'
       and periodo <= '2022-12';	  
 	 
	if _moro is null then
		let _moro = 0;
	end if
	   
	if _moro > 0 then
		continue foreach;
	end if
	   
    foreach 			
		select no_unidad,
		       cod_producto,
			   vigencia_inic,
		       vigencia_final,
			   cod_asegurado
		  into _no_unidad,
		       _cod_producto,
			   _vigencia_inic,
		       _vigencia_final,
			   _cod_asegurado	   
	      from emipouni
		 where no_poliza = v_no_poliza
		   
		select nombre
          into _contratante
          from cliclien
         where cod_cliente = _cod_contratante;

		select nombre
          into _asegurado
          from cliclien
         where cod_cliente = _cod_asegurado;
		
		select nombre
          into _producto
          from prdprod
         where cod_producto = _cod_producto;
		 
		select nombre
          into _grupo
          from cligrupo
         where cod_grupo = _cod_grupo;
		 
        return v_no_documento,
               _no_unidad,
               _vigencia_inic,
               _vigencia_final,
 			   _cod_contratante,
			   _contratante,
			   _cod_asegurado,
			   _asegurado,
			   _cod_producto,
			   _producto,
			   _cod_grupo,
			   _grupo with resume;
			   
	end foreach	   

END FOREACH;

END PROCEDURE