-- datos generados de prima cobrada - deivid
-- creado    : 29/05/2012 
-- autor: henry giron	 execute procedure sp_aud28("001","2012-04","2012-04")

drop procedure sp_aud28;
--create procedure "informix".sp_aud28(a_ano integer)
create procedure "informix".sp_aud28(a_compania	char(3),a_periodo1	char(7),a_periodo2	char(7))
returning	char(20),	 -- no_documento    
			char(10),	 -- no_poliza       
			char(3),	 -- cod_ramo        
			char(50),	 -- nombre_ramo     
			dec(16,2),	 -- monto           
			dec(16,2),	 -- prima		    
			dec(16,2),	 -- suma_asegurada 	
			date,		 -- vigencia_inic   
			date,		 -- vigencia_final  
			char(5),	 -- no_unidad       
			dec(16,2),	 -- suma_unidad 	
			char(10),	 -- cod_asegurado   
			char(100),	 -- nombre_asegurado
			date,		 -- fecha_recibo    
            char(10),	 -- no_recibo											
			smallint,	 -- tipo
			varchar(50); -- nombre_tipo

define _no_documento        char(20);
define _no_poliza        	char(10);
define _cod_asegurado    	char(10);
define _cod_ramo	     	char(3);
define _nombre_ramo		 	varchar(50);
define _nombre_asegurado 	varchar(100);
define _vigencia_inic       date;
define _vigencia_final      date;
define _suma_unidad			dec(16,2);
define _monto            	dec(16,2);
define _prima            	dec(16,2);
define _no_unidad			char(10);
define _no_recibo           char(10);
define _fecha_recibo      	date;
define _suma_asegurada   	dec(16,2); 	
define _tipo_incendio       smallint;							
define _nombre_tipo			varchar(50);

set isolation to dirty read;
create temp table tmp_data(
		no_documento    	char(20),
		no_poliza       	char(10),
		cod_ramo            char(3),
		nombre_ramo         char(50),
		monto           	dec(16,2),
		prima		    	dec(16,2),
		suma_asegurada 	    dec(16,2),
		vigencia_inic       date,
		vigencia_final      date,
		no_unidad           char(5),
		suma_unidad 	    dec(16,2),
		cod_asegurado       char(10),
		nombre_asegurado    char(100),
		fecha_recibo        date,
		no_recibo			char(10),		
		tipo_incendio       smallint,	
		nombre_tipo			varchar(50),
	    seleccionado        smallint default 1,
	    primary key		    (no_documento, no_poliza, cod_ramo, no_unidad, no_recibo)
	) with no log;


-- set debug file to "sp_aud28.trc";      
-- trace on;                                                                     

let _vigencia_inic  = current;
let _vigencia_final = current;
let _monto = 0.00;
let _prima = 0.00;

foreach
 select doc_remesa,
        monto,
	    prima_neta,
		no_poliza,
		no_recibo,
		fecha
   into _no_documento,
        _monto,
	    _prima,
		_no_poliza,  
		_no_recibo, 
		_fecha_recibo
   from cobredet
  where cod_compania = a_compania
    and actualizado  = 1
	and tipo_mov     in ('P', 'N')
    and periodo      >= a_periodo1
    and periodo      <= a_periodo2

	select cod_ramo,
		   vigencia_inic,
		   vigencia_final,
		   suma_asegurada
	  into _cod_ramo,
		   _vigencia_inic,
		   _vigencia_final,
		   _suma_asegurada
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo not in ("001","003","014") then 
		continue foreach;
	end if

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo; 	

	  LET _nombre_tipo  = '';
	foreach
	select cod_asegurado,
	       no_unidad,
		   suma_asegurada,
		   tipo_incendio
	  into _cod_asegurado,
	       _no_unidad,
		   _suma_unidad,
		   _tipo_incendio
	  from emipouni
	 where no_poliza = _no_poliza

		 IF _tipo_incendio = 1 THEN
		    LET _nombre_tipo  = 'Edificio';
		END IF

		 IF _tipo_incendio = 2 THEN
		    LET _nombre_tipo  = 'Contenido';
		END IF

		 IF _tipo_incendio = 3 THEN
		    LET _nombre_tipo  = 'Lucro Cesante';
		END IF


		 select nombre
		   into _nombre_asegurado
		   from cliclien
		  where cod_cliente = _cod_asegurado;

		begin
			on exception in(-239)
				update tmp_data
				   set monto        = monto + _monto,
				       prima        = prima + _prima
				 where no_documento = _no_documento
				   and no_poliza    = _no_poliza
				   and cod_ramo		= _cod_ramo
				   and no_unidad	= _no_unidad
				   and no_recibo    = _no_recibo ;
			end exception

			insert into tmp_data(
			no_documento,    	
			no_poliza,       	
			cod_ramo,          
			nombre_ramo,       
			monto,           	
			prima,		    	
			suma_asegurada, 	  
			vigencia_inic,     
			vigencia_final,    
			no_unidad,         
			suma_unidad, 	  
			cod_asegurado,     
			nombre_asegurado,  
			fecha_recibo,      
			no_recibo,			
			tipo_incendio,	
			nombre_tipo,
			seleccionado)
			values(
			_no_documento,
			_no_poliza,       	
			_cod_ramo,         
			_nombre_ramo,      
			_monto,           	
			_prima,		    	
			_suma_asegurada, 	
			_vigencia_inic,    
			_vigencia_final,   
			_no_unidad,        
			_suma_unidad, 	  
			_cod_asegurado,    
			_nombre_asegurado, 
			_fecha_recibo,     
			_no_recibo,	
			_tipo_incendio,
			_nombre_tipo,
			1);      

		end

	end foreach	
end foreach

foreach
	select no_documento,    	
	       no_poliza,       	
		   cod_ramo,         
		   nombre_ramo,      
		   monto,           	
		   prima,		    	
		   suma_asegurada, 	
		   vigencia_inic,    
		   vigencia_final,   
		   no_unidad,        
		   suma_unidad, 	  
		   cod_asegurado,    
		   nombre_asegurado, 
		   fecha_recibo,     
		   no_recibo,			
		   tipo_incendio,	
		   nombre_tipo	   
	  into _no_documento,
	       _no_poliza,       
		   _cod_ramo,        
		   _nombre_ramo,     
		   _monto,           
		   _prima,		    	
		   _suma_asegurada, 	
		   _vigencia_inic,   
		   _vigencia_final,  
		   _no_unidad,       
		   _suma_unidad, 	  
		   _cod_asegurado,   
		   _nombre_asegurado,
		   _fecha_recibo,    
		   _no_recibo,	
		   _tipo_incendio,
		   _nombre_tipo
	  from tmp_data
	 where seleccionado = 1


	   RETURN _no_documento,
			  _no_poliza,       
			  _cod_ramo,        
			  _nombre_ramo,     
			  _monto,           
			  _prima,		    	
	   		  _suma_asegurada, 	
			  _vigencia_inic,   
			  _vigencia_final,  
			  _no_unidad,       
			  _suma_unidad, 	  
			  _cod_asegurado,   
			  _nombre_asegurado,
			  _fecha_recibo,    
			  _no_recibo,	
			  _tipo_incendio,
			  _nombre_tipo		  
    	     WITH RESUME;
END FOREACH


drop table tmp_data;
end procedure



				