-- Procedimiento que Crea los Registros para ttcorp 
-- MAE_COMPROBANTES, DET_COMPROBANTES
-- 
-- Creado     : 11/12/2013 - Autor: Amado Perez
-- Modificado : 21/01/2014 - Autor: Angel Tello
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_ttc01;

create procedure "informix".sp_ttc01() 
returning int, 
		  varchar(100);   										   
																											   																											   
define _trx1_notrx           integer;								     -- trx1_notrx      										   
define _trx1_tipo            char(2);									 -- trx1_tipo       
define _trx1_comprobante     char(15);								     -- trx1_comprobante										   
define _trx1_fecha           date;									     -- trx1_fecha      										   
define _trx1_concepto        char(3);									 -- trx1_concepto   										   
define _trx1_ccosto          char(3);								     -- trx1_ccosto     										   
define _trx1_descrip         char(50);								     -- trx1_descrip    										   
define _trx1_monto           decimal(15,2);							     -- trx1_monto      										   
define _trx1_moneda          char(2);									 -- trx1_moneda     										   
define _trx1_debito          decimal(15,2);						     	 -- trx1_debito     										   
define _trx1_credito         decimal(15,2);							     -- trx1_credito    										   
define _trx1_status          char(1);									 -- trx1_status     										   
define _trx1_origen          char(3);									 -- trx1_origen     
define _trx1_usuario         char(15);								     -- trx1_usuario    
define _trx1_fechacap        datetime year to second;					 -- trx1_fechacap   

define _trx2_notrx           integer;									 -- trx2_notrx      
define _trx2_tipo            char(2);									 -- trx2_tipo       
define _trx2_linea           integer;									 -- trx2_linea      
define _trx2_cuenta          char(12);								     -- trx2_cuenta     
define _trx2_ccosto          char(3);									 -- trx2_ccosto     
define _trx2_debito          decimal(15,2);							     -- trx2_debito     
define _trx2_credito         decimal(15,2);							     -- trx2_credito    
define _trx2_actlzdo         char(1);                                    -- trx2_actlzdo


define _trx3_notrx           integer;									 -- trx3_notrx      
define _trx3_tipo            char(2);									 -- trx3_tipo       
define _trx3_lineatrx2       integer;								     -- trx3_lineatrx2  
define _trx3_linea           integer;									 -- trx3_linea      
define _trx3_cuenta          char(12);								  	 -- trx3_cuenta     
define _trx3_auxiliar        char(5);									 -- trx3_auxiliar   
define _trx3_debito          decimal(15,2);							     -- trx3_debito     
define _trx3_credito         decimal(15,2);							     -- trx3_credito    
define _trx3_actlzdo         char(1);								 	 -- trx3_actlzdo    
define _trx3_referencia      char(20);								     -- trx3_referencia 


define _trx2_no_poliza       char(12);                                   -- numero de poliza  
define _trx2_no_endozo       char(12);                                   -- numero de endoso 
define _trx2_ccosto_v        char(3);									 -- verificacion de centro de costo
define _trx2_no_remesa       char(12);									 -- numero de remesa
define _trx2_renglon	     smallint;									 -- renglon	
define _trx2_no_tranrec      char(12);                                   -- numero de poliza  
define _trx2_no_requis       char(12);                                   -- numero de requisiscion

define _cod_ttcorpccentro   char(50);									 -- codigo de centro de costo ttcorp
define _cnt_asien          	integer;                                     -- contador
define _cod_ramo		    char(5);									 -- codigo de ramo	
define _cnt_aux          	integer;								     -- contador auxiliar		
define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

define _cont          		integer;
define _contt          		integer;
define _mae_idcompro		integer;
set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || _error_desc;
end exception

let _cont = 0;
foreach
	select trx1_notrx, 
		   trx1_comprobante,
		   trx1_descrip,
		   trx1_fecha,
		   trx1_concepto,
		   trx1_origen
	  into _trx1_notrx, 
		   _trx1_comprobante,
		   _trx1_descrip,
		   _trx1_fecha,
		   _trx1_concepto,
		   _trx1_origen 
	  from cgltrx1

    insert into deivid_ttcorp:mae_comprobantes (
			id_comprobante,
			num_pista,
			bol_estado_reg,
			num_comprobante,
			des_comprobante,
			ind_comprobante,
			cod_moneda,
			por_factor_cambio1,
			por_factor_cambio2,
			cod_situacion,
			fec_situacion,
			cod_empresa)
    values (
		_trx1_notrx,
		9999,
		0,
		_trx1_notrx,
		_trx1_descrip,
		"A",
		"USD",
		0,
		0,
		5,
		current,
		11);
      
	  
	-- CGL 
	if _trx1_origen = "CGL" then

		foreach
			select trx2_notrx,
				   trx2_linea,
				   trx2_cuenta,   
				   trx2_ccosto,
				   trx2_debito,
	   			   trx2_credito
			  into _trx2_notrx,
				   _trx2_linea,
				   _trx2_cuenta,
				   _trx2_ccosto,
				   _trx2_debito, 
				   _trx2_credito
			  from cgltrx2
			 where trx2_notrx = _trx1_notrx 
			 
			 LET _trx2_cuenta = TRIM(_trx2_cuenta);

			select centro_costo
			  into _trx2_ccosto_v
			  from cglcuentas
			 where cta_cuenta = _trx2_cuenta;
			 
			 if _trx2_ccosto_v is null then
				let _trx2_ccosto_v = _trx2_ccosto;
			 end if
			
			select ttcorp_centro_costo
			  into _cod_ttcorpccentro
			  from cglcentro
			 where cen_codigo = _trx2_ccosto_v;
			 
			 if _cod_ttcorpccentro is null then
				return 1, "Codigo centro costo no encontrado, cuenta: "||_trx2_cuenta ;
			 end if
			
	         select count(*)
			   into _cnt_aux
			   from cgltrx3
			  where trx3_notrx     = _trx1_notrx
			    and trx3_lineatrx2 = _trx2_linea;

			if _cnt_aux > 0 then

			 	foreach 
			 		select trx3_notrx,
						   trx3_cuenta,
						   trx3_auxiliar,
						   trx3_debito,  
						   trx3_credito 
					  into _trx3_notrx,
						   _trx3_cuenta,
						   _trx3_auxiliar,
	       				   _trx3_debito,  
						   _trx3_credito 
					  from cgltrx3
					 where trx3_notrx     = _trx1_notrx
					   and trx3_lineatrx2 = _trx2_linea
					   
				
					  let _cont = _cont + 1;
				    
					   
				    insert into deivid_ttcorp:det_comprobantes (
							    id_comprobante,
								num_documento,
							    num_asiento,
							    mon_debito,
							    mon_credito,
								cod_segmento1,
								cod_segmento2,
								cod_segmento5)
						values(
							   _trx1_notrx,
							   _trx1_comprobante,
							   _cont, 
							   _trx3_debito,  
							   _trx3_credito,
							   _cod_ttcorpccentro,
							   _trx3_auxiliar,
							   _trx1_origen);   
				end foreach   

			 else
                
				
						let _cont = _cont + 1;
			 
			 
			    insert into deivid_ttcorp:det_comprobantes (
							   id_comprobante,
							   num_documento,
							   num_asiento,
							   mon_debito,
							   mon_credito,
							   cod_segmento1,
							   cod_segmento5)
						values(
								_trx1_notrx,
								_trx1_comprobante,
								_cont,
								_trx2_debito, 
								_trx2_credito,
								_cod_ttcorpccentro,
								_trx1_origen);   
		     end if	

		 end foreach
	let _cont = 0;
	
	-- COBROS 
	elif _trx1_origen = "COB" then
	     FOREACH
					select no_remesa,
						   renglon,
						   cuenta,   
						   centro_costo,
						   debito,
						   credito
					  into _trx2_no_remesa,
						   _trx2_renglon,
						   _trx2_cuenta,
						   _trx2_ccosto_v,
						   _trx2_debito, 
						   _trx2_credito
					  from sac999:cobasien
					 where sac_notrx = _trx1_notrx
					 
					select no_poliza
					  into _trx2_no_poliza
					  from cobredet
					 where no_remesa = _trx2_no_remesa 
					   and renglon = _trx2_renglon  ;
 
					 select cod_ramo
					   into _cod_ramo
					   from emipomae
					  where no_poliza = _trx2_no_poliza;
					 
					
				     LET _trx2_cuenta = TRIM(_trx2_cuenta);

					select centro_costo
					  into _trx2_ccosto_v
					  from cglcuentas
					 where cta_cuenta = _trx2_cuenta;
					 
					 if _trx2_ccosto_v is null then
						let _trx2_ccosto_v = _trx2_ccosto;
					 end if
					
					select ttcorp_centro_costo
					  into _cod_ttcorpccentro
					  from cglcentro
					 where cen_codigo = _trx2_ccosto_v;
					 
					 if _cod_ttcorpccentro is null then
						return 1, "Codigo centro costo no encontrado, cuenta: "||_trx2_cuenta ;
					 end if
					
					 select count(*)
					   into _cnt_aux
					   from sac999:cobasiau
					  where no_remesa   = _trx2_no_remesa
						and renglon 	= _trx2_renglon
						and cuenta 		= _trx2_cuenta;
					 
					 
					 if _cnt_aux > 0 then
						
						foreach
							 select cuenta,
									cod_auxiliar,
									centro_costo,
									debito,
									credito
							   into _trx3_cuenta,
									_trx3_auxiliar,
									_trx3_debito,  
									_trx3_credito
							   from sac999:cobasiau
							  where no_remesa   = _trx2_no_remesa
							    and renglon 	= _trx2_renglon
							    and cuenta 		= _trx2_cuenta
						
						let _cont = _cont + 1;
						-- insetar det_comprobantes trx3
						 insert into deivid_ttcorp:det_comprobantes (
										   id_comprobante,
										   num_asiento,
										   num_documento,
										   mon_debito,
										   mon_credito,
										   cod_segmento1,
										   cod_segmento2,
										   cod_segmento3,
										   cod_segmento5)
									values(
											_trx1_notrx,
											_cont,
											_trx1_comprobante,
											_trx3_debito, 
											_trx3_credito,
											_cod_ttcorpccentro,
											_trx3_auxiliar,
											_cod_ramo,
											_trx1_origen);   
						end foreach
					else 
						let _cont = _cont + 1;
					-- insetar det_comprobantes trx2
						 insert into deivid_ttcorp:det_comprobantes (
										   id_comprobante,
										   num_asiento,
										   num_documento,
										   mon_debito,
										   mon_credito,
										   cod_segmento1,
										   cod_segmento2,
										   cod_segmento5)
									values(
											_trx1_notrx,
											_cont,
											_trx1_comprobante,
											_trx3_debito, 
											_trx3_credito,
											_cod_ttcorpccentro,
											_cod_ramo,
											_trx1_origen);  
						
					end if
			END FOREACH
		let _cont = 0;
		
	 -- PRODUCION 
	elif _trx1_origen = "PRO" then
	     FOREACH
					select no_poliza,
						   no_endoso,
						   cuenta,   
						   centro_costo,
						   debito,
						   credito
					  into _trx2_no_poliza,
						   _trx2_no_endozo,
						   _trx2_cuenta,
						   _trx2_ccosto_v,
						   _trx2_debito, 
						   _trx2_credito
					  from sac999:endasien
					 where sac_notrx = _trx1_notrx
					 
					 select cod_ramo
					   into _cod_ramo
					   from emipomae
					  where no_poliza = _trx2_no_poliza;
					 
				     LET _trx2_cuenta = TRIM(_trx2_cuenta);

					select centro_costo
					  into _trx2_ccosto_v
					  from cglcuentas
					 where cta_cuenta = _trx2_cuenta;
					 
					 if _trx2_ccosto_v is null then
						let _trx2_ccosto_v = _trx2_ccosto;
					 end if
					
					select ttcorp_centro_costo
					  into _cod_ttcorpccentro
					  from cglcentro
					 where cen_codigo = _trx2_ccosto_v;
					 
					 if _cod_ttcorpccentro is null then
						return 1, "Codigo centro costo no encontrado, cuenta: "||_trx2_cuenta ;
					 end if
					
					 select count(*)
					   into _cnt_aux
					   from sac999:endasiau
					  where no_poliza   = _trx2_no_poliza
						and no_endoso 	= _trx2_no_endozo
						and cuenta 		= _trx2_cuenta;
					 
					 
					 if _cnt_aux > 0 then
						
						foreach
							 select cuenta,
									cod_auxiliar,
									centro_costo,
									debito,
									credito
							   into _trx3_cuenta,
									_trx3_auxiliar,
									_trx3_debito,  
									_trx3_credito
							   from sac999:endasiau
							  where no_poliza   = _trx2_no_poliza
								and no_endoso 	= _trx2_no_endozo
								and cuenta 		= _trx2_cuenta
							
						let _cont = _cont + 1;	
						-- insetar det_comprobantes trx3
						 insert into deivid_ttcorp:det_comprobantes (
										   id_comprobante,
										   num_asiento,
										   num_documento,
										   mon_debito,
										   mon_credito,
										   cod_segmento1,
										   cod_segmento2,
										   cod_segmento3,
										   cod_segmento5)
									values(
											_trx1_notrx,
											_cont,
											_trx1_comprobante,
											_trx3_debito, 
											_trx3_credito,
											_cod_ttcorpccentro,
											_trx3_auxiliar,
											_cod_ramo,
											_trx1_origen);   
						end foreach
					else 
					
					let _cont = _cont + 1;
					-- insetar det_comprobantes trx2
						 insert into deivid_ttcorp:det_comprobantes (
										   id_comprobante,
										   num_asiento,
										   num_documento,
										   mon_debito,
										   mon_credito,
										   cod_segmento1,
										   cod_segmento2,
										   cod_segmento3,
										   cod_segmento5)
									values(
											_trx1_notrx,
											_cont,
											_trx1_comprobante,
											_trx3_debito, 
											_trx3_credito,
											_cod_ttcorpccentro,
											_cod_ramo,
											_trx1_origen);  
					end if
			END FOREACH	
	 	let _cont = 0;
	 
	-- RECLAMOS
	elif _trx1_origen = "REC" then
	     FOREACH
					select no_tranrec,
						   cuenta,   
						   centro_costo,
						   debito,
						   credito
					  into _trx2_no_tranrec,
						   _trx2_cuenta,
						   _trx2_ccosto_v,
						   _trx2_debito, 
						   _trx2_credito
					  from sac999:recasien
					 where sac_notrx = _trx1_notrx
					 
				     LET _trx2_cuenta = TRIM(_trx2_cuenta);

					select centro_costo
					  into _trx2_ccosto_v
					  from cglcuentas
					 where cta_cuenta = _trx2_cuenta;
					 
					 if _trx2_ccosto_v is null then
						let _trx2_ccosto_v = _trx2_ccosto;
					 end if
					
					select ttcorp_centro_costo
					  into _cod_ttcorpccentro
					  from cglcentro
					 where cen_codigo = _trx2_ccosto_v;
					 
					 if _cod_ttcorpccentro is null then
						return 1, "Codigo centro costo no encontrado, cuenta: "||_trx2_cuenta ;
					 end if
					
					 select count(*)
					   into _cnt_aux
					   from sac999:recasiau
					  where no_tranrec   = _trx2_no_tranrec
						and cuenta 		= _trx2_cuenta;
					 
					 
					 if _cnt_aux > 0 then
						
						foreach
							 select cuenta,
									cod_auxiliar,
									centro_costo,
									debito,
									credito
							   into _trx3_cuenta,
									_trx3_auxiliar,
									_trx3_debito,  
									_trx3_credito
							   from sac999:recasiau
							  where no_tranrec   = _trx2_no_tranrec
								and cuenta 		= _trx2_cuenta
						
						let _cont = _cont + 1;		
						-- insetar det_comprobantes trx3
						 insert into deivid_ttcorp:det_comprobantes (
										   id_comprobante,
										   num_asiento,
										   num_documento,
										   mon_debito,
										   mon_credito,
										   cod_segmento1,
										   cod_segmento2,
										   cod_segmento3,
										   cod_segmento5)
									values(
											_trx1_notrx,
											_cont,
											_trx1_comprobante,
											_trx3_debito, 
											_trx3_credito,
											_cod_ttcorpccentro,
											_trx3_auxiliar,
											_trx1_origen);   
						end foreach
					else 
					let _cont = _cont + 1;
					-- insetar det_comprobantes trx2
						 insert into deivid_ttcorp:det_comprobantes (
										   id_comprobante,
										   num_asiento,
										   num_documento,
										   mon_debito,
										   mon_credito,
										   cod_segmento1,
										   cod_segmento2,
										   cod_segmento5)
									values(
											_trx1_notrx,
											_cont,
											_trx1_comprobante,
											_trx3_debito, 
											_trx3_credito,
											_cod_ttcorpccentro,
											_cod_ramo,
											_trx1_origen);  
					end if
			END FOREACH
		let _cont = 0;
		
	-- CHEQUES		
	elif _trx1_origen = "CHE" then
	     FOREACH
					select no_requisa,
					       renglon,
						   cuenta,   
						   centro_costo,
						   debito,
						   credito
					  into _trx2_no_requis,
						   _trx2_renglon,
						   _trx2_ccosto_v,
						   _trx2_debito, 
						   _trx2_credito
					  from deivid:chqchcta
					 where sac_notrx = _trx1_notrx
					 
				     LET _trx2_cuenta = TRIM(_trx2_cuenta);

					select centro_costo
					  into _trx2_ccosto_v
					  from cglcuentas
					 where cta_cuenta = _trx2_cuenta;
					 
					 if _trx2_ccosto_v is null then
						let _trx2_ccosto_v = _trx2_ccosto;
					 end if
					
					select ttcorp_centro_costo
					  into _cod_ttcorpccentro
					  from cglcentro
					 where cen_codigo = _trx2_ccosto_v;
					 
					 if _cod_ttcorpccentro is null then
						return 1, "Codigo centro costo no encontrado, cuenta: "||_trx2_cuenta ;
					 end if
					
					 select count(*)
					   into _cnt_aux
					   from deivid:chqctaux
					  where no_requisa  = _trx2_no_requis
					    and renglon     = _trx2_renglon
						and cuenta 		= _trx2_cuenta;
					 
					 if _cnt_aux > 0 then
						
						foreach
							 select cuenta,
									cod_auxiliar,
									centro_costo,
									debito,
									credito
							   into _trx3_cuenta,
									_trx3_auxiliar,
									_trx3_debito,  
									_trx3_credito
							   from deivid:chqctaux
							  where no_requisa  = _trx2_no_requis
								and renglon     = _trx2_renglon
								and cuenta 		= _trx2_cuenta
						let _cont = _cont + 1;		
						-- insetar det_comprobantes trx3
						 insert into deivid_ttcorp:det_comprobantes (
										   id_comprobante,
										   num_asiento,
										   num_documento,
										   mon_debito,
										   mon_credito,
										   cod_segmento1,
										   cod_segmento2,
										   cod_segmento5)
									values(
											_trx1_notrx,
											_cont,
											_trx1_comprobante,
											_trx3_debito, 
											_trx3_credito,
											_cod_ttcorpccentro,
											_trx3_auxiliar,
											_trx1_origen);   
						end foreach
					else 
					let _cont = _cont + 1;
					-- insetar det_comprobantes trx2
						 insert into deivid_ttcorp:det_comprobantes (
										   id_comprobante,
										   num_asiento,
										   num_documento,
										   mon_debito,
										   mon_credito,
										   cod_segmento1,
										   cod_segmento5)
									values(
											_trx1_notrx,
											_cont,
											_trx1_comprobante,
											_trx3_debito, 
											_trx3_credito,
											_cod_ttcorpccentro,
											_trx1_origen);  
					end if
			END FOREACH		
	
	let _cont = 0;
	-- COBROS 
	elif _trx1_origen = "REA" then
	     FOREACH
					select no_remesa,
						   renglon,
						   cuenta,   
						   centro_costo,
						   debito,
						   credito
					  into _trx2_no_remesa,
						   _trx2_renglon,
						   _trx2_cuenta,
						   _trx2_ccosto_v,
						   _trx2_debito, 
						   _trx2_credito
					  from sac999:cobasien
					 where sac_notrx = _trx1_notrx
					 
					select no_poliza
					  into _trx2_no_poliza
					  from cobredet
					 where no_remesa = _trx2_no_remesa 
					   and renglon = _trx2_renglon  ;
 
					 select cod_ramo
					   into _cod_ramo
					   from emipomae
					  where no_poliza = _trx2_no_poliza;
					 
					
				     LET _trx2_cuenta = TRIM(_trx2_cuenta);

					select centro_costo
					  into _trx2_ccosto_v
					  from cglcuentas
					 where cta_cuenta = _trx2_cuenta;
					 
					 if _trx2_ccosto_v is null then
						let _trx2_ccosto_v = _trx2_ccosto;
					 end if
					
					select ttcorp_centro_costo
					  into _cod_ttcorpccentro
					  from cglcentro
					 where cen_codigo = _trx2_ccosto_v;
					 
					 if _cod_ttcorpccentro is null then
						return 1, "Codigo centro costo no encontrado, cuenta: "||_trx2_cuenta ;
					 end if
					
					 select count(*)
					   into _cnt_aux
					   from sac999:cobasiau
					  where no_remesa   = _trx2_no_remesa
						and renglon 	= _trx2_renglon
						and cuenta 		= _trx2_cuenta;
					 
					 
					 if _cnt_aux > 0 then
						
						foreach
							 select cuenta,
									cod_auxiliar,
									centro_costo,
									debito,
									credito
							   into _trx3_cuenta,
									_trx3_auxiliar,
									_trx3_debito,  
									_trx3_credito
							   from sac999:cobasiau
							  where no_remesa   = _trx2_no_remesa
							    and renglon 	= _trx2_renglon
							    and cuenta 		= _trx2_cuenta
						let _cont = _cont + 1;		
						-- insetar det_comprobantes trx3
						 insert into deivid_ttcorp:det_comprobantes (
										   id_comprobante,
										   num_asiento,
										   num_documento,
										   mon_debito,
										   mon_credito,
										   cod_segmento1,
										   cod_segmento2,
										   cod_segmento3,
										   cod_segmento5)
									values(
											_trx1_notrx,
											_cont,
											_trx1_comprobante,
											_trx3_debito, 
											_trx3_credito,
											_cod_ttcorpccentro,
											_trx3_auxiliar,
											_cod_ramo,
											_trx1_origen);   
						end foreach
					else
					let _cont = _cont + 1;
					-- insetar det_comprobantes trx2
						 insert into deivid_ttcorp:det_comprobantes (
										   id_comprobante,
										   num_asiento,
										   num_documento,
										   mon_debito,
										   mon_credito,
										   cod_segmento1,
										   cod_segmento2,
										   cod_segmento3,
										   cod_segmento5)
									values(
											_trx1_notrx,
											_cont,
											_trx1_comprobante,
											_trx3_debito, 
											_trx3_credito,
											_cod_ttcorpccentro,
											_cod_ramo,
											_trx1_origen);  
					end if
			END FOREACH
		let _cont = 0;
			
		end if
end foreach


foreach

	select id_comprobante
	  into _mae_idcompro
	  from deivid_ttcorp:mae_comprobantes
    
	select count(*)
	  into _cnt_asien
	  from deivid_ttcorp:det_comprobantes
	 where id_comprobante = _mae_idcompro;
	 
	update deivid_ttcorp:mae_comprobantes
	   set num_asientos = _cnt_asien
	 where id_comprobante = _mae_idcompro;
end foreach

end

return 0, "Actualizacion Exitosa";

end procedure;
