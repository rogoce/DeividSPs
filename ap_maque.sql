DROP procedure ap_maque;
   CREATE procedure "informix".ap_maque()
   
   RETURNING 	CHAR(20)	as	v_poliza,
                DATE        as  v_vigencia_inic,
                DATE        as  v_vigencia_final,
 				CHAR(1)	    as  v_nueva_renov;				
   
 --  RETURNING CHAR(20),CHAR(3),DECIMAL(16,2),DECIMAL(16,2);   
   
   ---,CHAR(50),CHAR(45),INT,SMALLINT,DECIMAL(16,2),INTEGER,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),INTEGER,INTEGER,INTEGER,INTEGER,INTEGER,INTEGER;
--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL 
---  Armando Moreno M. 21/02/2002
---  Modificado: Amado Perez M. 12/03/2013 -- Se agrega el ramo 022 de equipo pesado a Ramos Tecnicos
---  Ref. Power Builder - d_sp_pro03b
-- execute procedure sp_pro4959('001','001','2016-06', '2016-06', '%')
--------------------------------------------
    DEFINE _no_poliza           CHAR(10);	
	define _cod_ramo_ori        CHAR(3);
	define _cod_ramo            CHAR(3);	
	define _no_documento        CHAR(20);
	define _no_unidad           CHAR(5);
	define _total_pri_sus		DECIMAL(16,2);		
	define _suma_asegurada		DECIMAL(16,2);	
	define _uso_auto            CHAR(1);	
	define _cobertura           CHAR(1);
	define _cnt_cobertura, _cnt_limite, _agregar       SMALLINT;
	define _no_endoso           CHAR(5);
	DEFINE _filtros, v_filtros  CHAR(255);
	DEFINE _descr_cia	        CHAR(45);		
	define _suscrita_unidad     DECIMAL(16,2);	
	define _sa_poliza           DECIMAL(16,2);
	define _valor           DECIMAL(16,2);	
	define _emipouni_sa,_emipouni_ps DECIMAL(16,2);	
	define _prioridad           SMALLINT;
	define _cnt_unidad          SMALLINT;
	define _3ciclo              SMALLINT;
	define _primera_u,_orden  SMALLINT;	
	define _unidad_pri_sus		DECIMAL(16,2);		
	define _c1,_c2,_c3,_c4,_c5,_c6,_c7,_c8,_c9,_c10,_c11,_c12	SMALLINT;
	define _p1,_P2,_p3,_p4,_p5,_p6,_p7,_p8,_p9,_p10,_p11,_p12   smallint;
	define _cod_subramo		    CHAR(3);
	
	define  _descripcion        CHAR(100);
	define  _auto_co_p_cant	INTEGER;
	define	_auto_co_p_monto	DECIMAL(16,2);
	define	_auto_co_c_cant	INTEGER;
	define	_auto_co_c_monto	DECIMAL(16,2);
	define	_auto_rc_p_cant	INTEGER;
	define	_auto_rc_p_monto	DECIMAL(16,2);
	define	_auto_rc_c_cant	INTEGER;
	define	_auto_rc_c_monto	DECIMAL(16,2);
	define	_soda_co_p_cant	INTEGER;
	define	_soda_co_p_monto	DECIMAL(16,2);
	define	_soda_co_c_cant	INTEGER;
	define	_soda_co_c_monto	DECIMAL(16,2);
	define	_sub_p_tot_cant	INTEGER;
	define	_sub_p_tot_monto	DECIMAL(16,2);
	define	_sub_c_tot_cant	INTEGER;
	define	_sub_c_tot_monto	DECIMAL(16,2);
	define _tot_cant	INTEGER;
	define _tot_monto  DECIMAL(16,2);
	DEFINE _mes2,_mes,_ano2   SMALLINT;
	DEFINE _fecha2     	      DATE;
	DEFINE _cnt_prima_nva, _cnt_prima_ren INTEGER;
	DEFINE _cod_tipoveh 	CHAR(3);
	DEFINE _grupo           CHAR(3);
	DEFINE _cod_producto    CHAR(5);
	DEFINE _no_motor        CHAR(30);
	DEFINE _cnt             SMALLINT;
	DEFINE _grupo_s         CHAR(30);
	DEFINE _nueva_renov     CHAR(1);
	DEFINE _tot_cant_sum    INTEGER;
	DEFINE _tot_cant_uni    INTEGER;
	DEFINE _vigencia_inic, _vigencia_final DATE;
	

--SET DEBUG FILE TO "sp_pro4963.trc"; 
--trace on;


FOREACH
	SELECT no_poliza, 
	       no_documento, 
		   vigencia_inic, 
		   vigencia_final,
		   nueva_renov
	  INTO _no_poliza, 
	       _no_documento, 
		   _vigencia_inic, 
		   _vigencia_final,
		   _nueva_renov
	  FROM estpolvih
	 where periodo = '2023-12' and cod_ramo in ('002','020','023')
	 
	let _agregar = 0; 
	 
	 FOREACH
		SELECT no_unidad
		  INTO _no_unidad
		  FROM emipouni
		 WHERE no_poliza = _no_poliza
		 
		let _cnt_cobertura = 0; 
		let _cnt_limite = 0; 
		 
		select count(*)
		  into _cnt_cobertura   -- Colision y Vuelco
		  from emipocob a, prdcober b 
		 where a.cod_cobertura = b.cod_cobertura
		   and a.no_poliza = _no_poliza
		   and a.no_unidad = _no_unidad
		   and b.nombre like "%COLISION%";			 
		 
		if _cnt_cobertura = 0 then
			select count(*)
			  into _cnt_limite   -- Colision y Vuelco
			  from emipocob a, prdcober b 
			 where a.cod_cobertura = b.cod_cobertura
			   and a.no_poliza = _no_poliza
			   and a.no_unidad = _no_unidad
			   and b.nombre like "%AJENA%"
               and a.limite_1 > 5000;
			 
            if _cnt_limite > 0 then
				let _agregar = 1;
			end if			   
		end if
	END FOREACH	
	
    if _agregar = 1 then
		return _no_documento,
		       _vigencia_inic,
			   _vigencia_final,
			   _nueva_renov with resume; 
		
    end if	
END FOREACH
	 

END PROCEDURE;
