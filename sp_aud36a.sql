-- Procedure para auditoria interna - Archivo de Reclamo - Leyri Moreno
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud36a;		
create procedure sp_aud36a(a_compania char(3), a_periodo1 char(7), a_periodo2 char(7), a_ramo char(255) default '*')
Returning VARCHAR(50) as ramo_nombre,
		CHAR(20) as no_poliza,
		CHAR(18) as numrecla,
		CHAR(10) as no_tramite,
		CHAR(7) as periodo,
		CHAR(50) as tipo_transaccion, 
		CHAR(10) as no_transaccion,
		CHAR(50) as tipo_pago,
		CHAR(50) as n_concepto,
		DEC(16,2) as mano_obra,	
		DEC(16,2) as pieza,	
		DEC(16,2) as monto,	
		CHAR(50) as ajustador, 	
		DATE as fecha_pagado,  	
		varchar(50) as perdida_total,
		CHAR(20) as estado_audiencia,
		CHAR(50) as n_cobertura;											

define _no_documento	char(20);		  
define _cod_ramo        char(3);
define v_ramo_nombre	varchar(50);
define _no_tramite      char(10);
define _periodo 		char(7);
define _cod_tipotran    char(3);
define _nom_rectitra    char(50);
define _transaccion		char(10);
define _tipo_pago_nom   varchar(50);
define _n_concepto      char(50);
define _cod_concepto    char(3);
define _ajust_nombre	varchar(50);
define _causa           varchar(50);
define _fecha_pagado            date;
define _estatus_audiencia       smallint;
define _n_estatus_audiencia     char(20);
define _n_cod_cobertura         char(50);
define _no_reclamo		        char(10);
define _cod_tipopago            char(3);
define _cnt             smallint;
define _numrecla		char(20);
define _monto			dec(16,2);
define _no_tranrec      char(10);
define _perd_total      smallint;
define _cod_cobertura   char(5);
define _no_poliza         char(10);
define _estatus_poliza    smallint;
define _monto_pza_t		  dec(16,2);
define _monto_pza_c		  dec(16,2);
define _monto_pza_r		  dec(16,2);
define _tipo_ord_comp     char(1);
define _pagado        	  smallint;
define _no_orden  		  char(10);
define _no_unidad		char(5);
define _ajust_interno	char(3);
define _fecha			date;
define _fecha1			date;
define _fecha2			date;

  drop table if exists tmp_transaccion;
CREATE TEMP TABLE tmp_transaccion
         (no_reclamo        CHAR(10),
		  transaccion	    CHAR(10),
          monto_pieza       DEC(16,2),
		  monto_man_obr     DEC(16,2),
		  primary key (no_reclamo,transaccion)) with no log;	  

set isolation to dirty read;
--set debug file to "sp_aud36a.trc";
--trace on;
--let a_periodo1 = a_periodo1;
--let a_periodo2 = a_periodo2;

let _fecha1 = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]);   -- sp_sis36(a_periodo1); 
let _fecha2 = sp_sis36(a_periodo2);

foreach 
select no_reclamo,
	       no_documento,
		   ajust_interno,
		   no_poliza,
		   perd_total,
		   numrecla,
		   no_tramite,
		   estatus_audiencia
	  into _no_reclamo,
	       _no_documento,
		   _ajust_interno,
		   _no_poliza,
		   _perd_total,
		   _numrecla,
		   _no_tramite,
		   _estatus_audiencia
	  from recrcmae
	 where numrecla[1,2] in ("02", "20", "23")
	   and fecha_reclamo >= _fecha1 -- "01-01-2017"
	   and fecha_reclamo <= _fecha2 -- "31-08-2017"
	   and actualizado = 1
	   
	   if  _estatus_audiencia = 0 then 
	       LET _n_estatus_audiencia = 'Perdido';
	   ELIF _estatus_audiencia = 1 then 
	       LET _n_estatus_audiencia = 'Ganado' ;
	   ELIF _estatus_audiencia = 2 then 
	       LET _n_estatus_audiencia = 'Por Definir'; 
	   ELIF _estatus_audiencia = 3 then 
	       LET _n_estatus_audiencia = 'Proceso Penal'; 
	   ELIF  _estatus_audiencia = 4 then 
	       LET _n_estatus_audiencia = 'Proceso Civil'; 
	   ELIF _estatus_audiencia = 5 then 
	       LET _n_estatus_audiencia = 'Apelacion' ;
	   ELIF _estatus_audiencia = 6 then 
	       LET _n_estatus_audiencia = 'Resuelto'; 
	   ELIF _estatus_audiencia = 7 then 
	       LET _n_estatus_audiencia = 'FUT - Ganado';
	   ELse  
	       LET _n_estatus_audiencia = 'FUT - Responsable';
	   end if


		foreach
		select no_tranrec,
				cod_tipopago,
				transaccion,				
				monto,
				numrecla,
				fecha_pagado,
				pagado,				
				periodo,
				cod_tipotran
		   into _no_tranrec,
				_cod_tipopago,				
				_transaccion,				
				_monto,
				_numrecla,
				_fecha_pagado,
				_pagado,				
				_periodo,
				_cod_tipotran		
		   from	rectrmae
		  where no_reclamo    = _no_reclamo
			and actualizado   = 1
			and cod_tipotran  = "004"	--Pago de reclamo
			and monto         <> 0
		--  and no_requis     is not null
			and pagado        = 1
			and anular_nt     is null
		  order by fecha
		  
		   select count(*)
		     into _cnt
			 from rectrcob
			where no_tranrec = _no_tranrec
			  and cod_cobertura in('00119','00121','01307','00113','00671','01022','01304');
             			
            if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt = 0 then
				continue foreach;
			end if
			let _causa = "";
			if _perd_total = 1 then
				let _causa = "PERDIDA TOTAL";
			end if

			select nombre
			  into _ajust_nombre
			  from recajust
			 where cod_ajustador = _ajust_interno;

			select nombre
			  into _tipo_pago_nom
			  from rectipag
			 where cod_tipopago = _cod_tipopago;
			 
			foreach
				select a.cod_concepto, b.cod_cobertura
				  into _cod_concepto, _cod_cobertura
				  from rectrcon a, rectrcob b
				 where a.no_tranrec = _no_tranrec
				   and a.no_tranrec = b.no_tranrec
				   and b.cod_cobertura in('00119','00121','01307','00113','00671','01022','01304')
				   and a.monto <> 0
				   exit foreach;
			end foreach		   

			
			let _monto_pza_r = 0;
  		    let _monto_pza_c = 0;
			let _monto_pza_t = 0;

            foreach
				select monto, tipo_ord_comp
				  into _monto_pza_t, _tipo_ord_comp
				  from recordma
				 where transaccion = _transaccion
				 
				 if _tipo_ord_comp = 'C' then 
					let _monto_pza_c = _monto_pza_c + (_monto_pza_t * 7 / 100);
				end if
				
				 if _tipo_ord_comp = 'R' then 
					let _monto_pza_r = _monto_pza_r + _monto_pza_t ;
				end if					
							  
					BEGIN
					ON EXCEPTION IN(-239)
						UPDATE tmp_transaccion			   
						   SET monto_pieza   = monto_pieza   + _monto_pza_c,
							   monto_man_obr = monto_man_obr + _monto_pza_r
						 where no_reclamo = _no_reclamo
						   and transaccion = _transaccion;
							   
					END EXCEPTION
						INSERT INTO tmp_transaccion
					   VALUES(_no_reclamo,
							  _transaccion,
							  _monto_pza_c,
							  _monto_pza_r);
					END		  					
			end foreach															
			
			select monto_pieza, monto_man_obr
			  into _monto_pza_c,_monto_pza_r
			  from tmp_transaccion
             where no_reclamo = _no_reclamo
			   and transaccion = _transaccion;			  			  																
			   
			    if _monto_pza_c is null then
			       let _monto_pza_c = 0;
			   end if					   
			    if _monto_pza_r is null then
			       let _monto_pza_r = 0;
			   end if					   
					
			select cod_ramo
			  into _cod_ramo
			  from emipomae
			 where no_poliza = _no_poliza;	  					
							
			select nombre
			  into v_ramo_nombre
			  from prdramo 
			 where cod_ramo = _cod_ramo;						

			select nombre
			  into _nom_rectitra
			  from rectitra
			 where cod_tipotran =  _cod_tipotran;			 
			 
			select nombre 
			  into _n_concepto
			  from recconce
			 where cod_concepto = _cod_concepto	; 				 
			 
			select nombre
			  into _n_cod_cobertura
			  from prdcober 
			 where cod_cobertura = _cod_cobertura;					 		

			return v_ramo_nombre,
					_no_documento,
					_numrecla,
					_no_tramite,
					_periodo,
					_nom_rectitra, 
					_transaccion,
					_tipo_pago_nom,
					_n_concepto,
					_monto_pza_r,	
					_monto_pza_c,	
					_monto,	
					_ajust_nombre, 	
					_fecha_pagado,  	
					_causa,
					_n_estatus_audiencia,
					_n_cod_cobertura 
			   with resume;			

		end foreach
end foreach
--trace off;
end procedure