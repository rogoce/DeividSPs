-- Arreglar los productos de Salud para que se puedan utilizar
-- en los reclamos automaticos

drop procedure sp_par45;

create procedure sp_par45(a_cod_producto char(5))
returning integer, char(100);

define _cod_ramo           char(3);  
define _cod_subramo        char(3);  
define _cod_producto       char(5);  
define _cod_cobertura      char(5);  

define _orden              smallint; 
define _se_audita          smallint; 
define _maneja_tipo_cob    smallint; 
define _desp_del_deducible smallint; 
define _deducible_local    dec(16,2);
define _deducible_fuera    dec(16,2);
define _forma_pagar        char(1);  
define _co_pago            dec(16,2);
define _lim_anual_tipo     char(1);  
define _lim_anual_monto    dec(16,2);
define _lim_vit_tipo       char(1);  
define _lim_vit_monto      dec(16,2);
define _relacionado_a      char(1);  
define _porc_med_partic    dec(5,2); 
define _cod_tipo           char(3);  
define _desc_limite1	   char(50);
define _desc_limite2	   char(50);
	
define _deduc_loc_009	   dec(16,2);
define _deduc_fue_009	   dec(16,2);
define _error			   integer;

begin 
on exception set _error 
 	return _error, "Error en la Actualizacion ...";         
end exception
	
	
select cod_ramo,
       cod_subramo
  into _cod_ramo,
       _cod_subramo
  from prdprod
 where cod_producto = a_cod_producto;

foreach
 select	cod_producto,
	   deducible_local,
	   deducible_fuera
   into	_cod_producto,
	   _deduc_loc_009,
	   _deduc_fue_009
   from	prdprod
  where	cod_ramo     = _cod_ramo
    and cod_subramo  = _cod_subramo
    and cod_producto <> a_cod_producto

	delete from prdcobsa
     where cod_producto  = _cod_producto;

	foreach
	 select	cod_cobertura,
			orden,             
			se_audita,         
			maneja_tipo_cob,   
			desp_del_deducible,
			deducible_local,   
			deducible_fuera,   
			forma_pagar,       
			co_pago,           
			lim_anual_tipo,    
			lim_anual_monto,   
			lim_vit_tipo,      
			lim_vit_monto,     
			relacionado_a,
			desc_limite1,	  
			desc_limite2	  
	   into	_cod_cobertura,
			_orden,             
			_se_audita,         
			_maneja_tipo_cob,   
			_desp_del_deducible,
			_deducible_local,   
			_deducible_fuera,   
			_forma_pagar,       
			_co_pago,           
			_lim_anual_tipo,    
			_lim_anual_monto,   
			_lim_vit_tipo,      
			_lim_vit_monto,     
			_relacionado_a,
			_desc_limite1,	  
			_desc_limite2	  
	   from prdcobpd
	  where cod_producto = a_cod_producto

		update prdcobpd
		   set orden              =	_orden,             
			   se_audita          = _se_audita,         
			   maneja_tipo_cob    = _maneja_tipo_cob,   
			   desp_del_deducible = _desp_del_deducible,
			   deducible_local    =	_deducible_local,   
			   deducible_fuera    = _deducible_fuera,   
			   forma_pagar        = _forma_pagar,       
			   co_pago            = _co_pago,           
			   lim_anual_tipo     = _lim_anual_tipo,    
			   lim_anual_monto    = _lim_anual_monto,   
			   lim_vit_tipo       = _lim_vit_tipo,      
			   lim_vit_monto      =	_lim_vit_monto,     
			   relacionado_a	  =	_relacionado_a	  
		 where cod_producto       = _cod_producto
		   and cod_cobertura      = _cod_cobertura;

  			if _cod_subramo   =  "009"   and
			   _cod_cobertura <> "00570" then
				update prdcobpd
				   set desc_limite1       =	_desc_limite1,
					   desc_limite2       = _desc_limite2
				 where cod_producto       = _cod_producto
				   and cod_cobertura      = _cod_cobertura;
			end if		

		foreach
		 select	cod_tipo,
		 		desp_del_deducible,
				deducible_local,   
				deducible_fuera,   
				forma_pagar,       
				co_pago,           
				lim_anual_tipo,    
				lim_anual_monto,   
				lim_vit_tipo,      
				lim_vit_monto,     
				porc_med_partic
		   into	_cod_tipo,
		   		_desp_del_deducible,
				_deducible_local,   
				_deducible_fuera,   
				_forma_pagar,       
				_co_pago,           
				_lim_anual_tipo,    
				_lim_anual_monto,   
				_lim_vit_tipo,      
				_lim_vit_monto,     
				_porc_med_partic
		   from prdcobsa
		  where cod_producto  = a_cod_producto
		    and cod_cobertura = _cod_cobertura

  			if _cod_subramo   = "009"   and
			   _cod_cobertura = "00552" and
			   _cod_tipo      = "004"   then
				let _deducible_local = _deduc_loc_009;
				let _deducible_fuera = _deduc_fue_009;
			end if

			insert into prdcobsa(
			cod_producto,
			cod_cobertura,
			cod_tipo,
	 		desp_del_deducible,
			deducible_local,   
			deducible_fuera,   
			forma_pagar,       
			co_pago,           
			lim_anual_tipo,    
			lim_anual_monto,   
			lim_vit_tipo,      
			lim_vit_monto,     
			porc_med_partic
			)
			values(
			_cod_producto,
			_cod_cobertura,
			_cod_tipo,
	 		_desp_del_deducible,
			_deducible_local,   
			_deducible_fuera,   
			_forma_pagar,       
			_co_pago,           
			_lim_anual_tipo,    
			_lim_anual_monto,   
			_lim_vit_tipo,      
			_lim_vit_monto,     
			_porc_med_partic
			);

		end foreach

	end foreach

end foreach

return 0, "Actualizacion Exitosa ...";

end

end procedure 
