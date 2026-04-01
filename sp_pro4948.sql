------------------------------------------------
--      EMICARTASAL2          --
--         CONTRATO DE REASEGURO              --
---  Henry Giron - 10/12/2011 --
------------------------------------------------
drop procedure sp_pro4948;
create procedure sp_pro4948(a_periodo char(7),
							a_imp1 smallint default 0,
							a_imp2 smallint default 0,
							a_envi1 smallint default 0,
							a_envi2 smallint default 0,
							a_envi3 smallint default 0,
							a_envi4 smallint default 0,
							a_poliza char(20) default "%"
						   )
returning	char(100),
			char(100),
			char(10),
			char(10),
			char(10),
			char(20),
			char(3),
			char(3),
			char(3),
			date,
			char(50),
			char(5),
			dec(16,2),
			char(7),
			char(100),
			dec(16,2),
			dec(16,2),
			char(100),
			dec(16,2),
			char(100),
			varchar(50);
																																												  
--integer li_imp1, li_imp2, li_envi1, li_envi2, li_envi3, li_envi4																												  
--string ls_periodo,ls_poliza
begin

define _nombre_zona		varchar(50);
define _nombre_cliente	char(100);
define _deducible_txt	char(100);
define _name_cliclien	char(100);
define _nombre_plan     char(100);
define _direccion		char(100);
define _nombre_agente	char(50);
define _no_documento	char(20);
define _deducible_din	char(18);
define _telefono1		char(10);
define _telefono2		char(10);
define _no_poliza		char(10);
define _celular      	char(10);
define _periodo			char(7);
define _cod_producto	char(5);
define _cod_agente		char(5);
define _cod_vendedor	char(3);
define _cod_formapag	char(3);
define _cod_subramo		char(3);
define _cod_perpago		char(3);
define _deducible_int	dec(16,2);
define _deducible		dec(16,2);
define _co_pago			dec(16,2);
define _prima			dec(16,2);
define _fecha_aniv		date;

--	set debug file to "sp_pro4939.trc";
--	trace on;

     create temp table temp_carta2012
			  (nombre_cliente	char(100), 
			   direccion    	char(100), 
			   telefono1    	char(10),	
			   telefono2    	char(10),	
			   celular      	char(10),	
			   no_documento		char(20),	
			   cod_subramo  	char(3),	
			   cod_formapag 	char(3),	
			   cod_perpago  	char(3),	
			   fecha_aniv   	date,	
			   nombre_agente	char(50),	
			   cod_producto 	char(5), 
			   prima      		decimal(16,2),
			   periodo    		char(7), 
			   name_cliclien    char(100),
			   deducible		dec(16,2),	
			   co_pago  		dec(16,2),	
			   nombre_plan      char(100),
			   deducible_int	dec(16,2),
			   deducible_txt    char(100),
			   zona             varchar(50)
            ) with no log;
										 
	create index idx1_temp_carta2012 on temp_carta2012(no_documento);
	create index idx2_temp_carta2012 on temp_carta2012(cod_subramo);
	create index idx3_temp_carta2012 on temp_carta2012(periodo);
	create index idx4_temp_carta2012 on temp_carta2012(zona);

foreach
  select distinct emicartasal2.nombre_cliente,   
         emicartasal2.direccion,   
         emicartasal2.telefono1,   
         emicartasal2.telefono2,   
         emicartasal2.celular,   
         emicartasal2.no_documento,   
         emicartasal2.cod_subramo,   
         emicartasal2.cod_formapag,   
         emicartasal2.cod_perpago,   
         emicartasal2.fecha_aniv,   
         emicartasal2.nombre_agente,   
         emicartasal2.cod_producto,   
         emicartasal2.prima,   
         emicartasal2.periodo,   
         cliclien.nombre,
		 emicartasal2.deducible,   
		 emicartasal2.co_pago,
         emicartasal2.nombre_plan,
		 emicartasal2.deducible_int
    into _nombre_cliente, 
		 _direccion, 
		 _telefono1, 
		 _telefono2, 
		 _celular,
 		 _no_documento,
		 _cod_subramo, 
		 _cod_formapag, 
		 _cod_perpago, 
		 _fecha_aniv, 
		 _nombre_agente, 
		 _cod_producto, 
		 _prima, 
		 _periodo, 
		 _name_cliclien,
		 _deducible,		
		 _co_pago,  		
		 _nombre_plan,
		 _deducible_int	 		   
    from emicartasal2,   
         emipomae,   
         cliclien  
   where (emicartasal2.no_documento	= emipomae.no_documento ) and  
         (emipomae.cod_contratante	= cliclien.cod_cliente ) and  
         (trim(emicartasal2.nombre_plan) = "SALUD PANAMA" ) and		 
        ((emicartasal2.periodo		= a_periodo ) and  
         (emicartasal2.impreso		= a_imp1 or  
         emicartasal2.impreso		= a_imp2) and  
         emicartasal2.enviado_a		in (a_envi1,a_envi2,a_envi3,a_envi4) and  
--         emicartasal2.cod_subramo in ('007','009') and  
         emicartasal2.no_documento	like a_poliza )   
order by emicartasal2.nombre_agente	asc,   
         emicartasal2.no_documento	asc   	 

	   let _deducible_din = _deducible_int ;

	   if _cod_subramo = "009" then  -- Para Global se adiciona el deducible internacional
			let _deducible_txt = " LOCAL B/. "||_deducible||" / Internacional B/. "||_deducible_din; --_deducible_int;
	   else
			let _deducible_txt = " B/. "||_deducible;
	   end if

	   let _no_poliza = sp_sis21(_no_documento);
	   foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			 
			 exit foreach;

	   end foreach

	   select cod_vendedor
	     into _cod_vendedor
		 from parpromo
        where cod_agente  = _cod_agente
		  and cod_agencia = '001'
		  and cod_ramo	  =	'018';

		  let _nombre_zona = "";

   	   select nombre
	     into _nombre_zona
	     from agtvende
	    where cod_vendedor = _cod_vendedor;
	   
		   	insert into temp_carta2012(nombre_cliente,
			                        direccion,    	
									telefono1,    	
									telefono2,    	
									celular,      	
									no_documento,		
									cod_subramo, 	
									cod_formapag, 	
									cod_perpago,	
									fecha_aniv,	
									nombre_agente,	
									cod_producto,	
									prima,	
						            periodo,	
									name_cliclien,
									deducible,		
									co_pago,  		
									nombre_plan,
									deducible_int,
									deducible_txt,
									zona									
									  )  
			    	     values(    _nombre_cliente,  
							  		_direccion, 
							  		_telefono1, 
							  		_telefono2, 
							  		_celular, 
							  		_no_documento,
							  		_cod_subramo, 
							  		_cod_formapag, 
							  		_cod_perpago, 
			    			  		_fecha_aniv, 
			    			  		_nombre_agente, 
			    			  		_cod_producto, 
			    			  		_prima, 
			    			  		_periodo, 
			     			  	  	_name_cliclien,
			     			  	  	_deducible,		
			     			  	  	_co_pago,  		
			     			  	  	_nombre_plan,
									_deducible_int,
									_deducible_txt,
									_nombre_zona
			     			  	  	 );	 
			    
end foreach


foreach
     select nombre_cliente,
			direccion,    	
			telefono1,    	
			telefono2,    	
			celular,      	
			no_documento,	
			cod_subramo, 	
			cod_formapag, 	
			cod_perpago,	
			fecha_aniv,	
			nombre_agente,	
			cod_producto,	
			prima,	
			periodo,	
			name_cliclien,
	  	  	deducible,		
	  	  	co_pago,  		
	  	  	nombre_plan,
	  	  	deducible_int,
	  	  	deducible_txt,
	  	  	zona					  								
       into _nombre_cliente,
			_direccion, 
			_telefono1, 
			_telefono2, 
			_celular, 
	        _no_documento, 
			_cod_subramo, 
			_cod_formapag, 
			_cod_perpago, 
			_fecha_aniv, 
			_nombre_agente, 
			_cod_producto, 
			_prima, 
			_periodo, 
			_name_cliclien,
	  	  	_deducible,		
	  	  	_co_pago,  		
	  	  	_nombre_plan,
	  	  	_deducible_int,
	  	  	_deducible_txt,
			_nombre_zona
       from temp_carta2012	
	  order by nombre_agente asc, zona, no_documento asc   

	         return _nombre_cliente,	--01
					_direccion,			--02
					_telefono1,			--03
					_telefono2,			--04
					_celular,			--05
			        _no_documento,		--06
					_cod_subramo,		--07
					_cod_formapag,		--08
					_cod_perpago,		--09
					_fecha_aniv,		--10
					_nombre_agente,		--11
					_cod_producto,		--12
					_prima,				--13
					_periodo,			--14
					_name_cliclien,		--15
			  	  	_deducible,			--16		
			  	  	_co_pago,			--17  		
			  	  	_nombre_plan,		--18
					_deducible_int,		--19
					_deducible_txt,		--20
					_nombre_zona		--21
	                with resume;


end foreach

drop table temp_carta2012;
end

end procedure  

 
		