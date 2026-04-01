drop procedure sp_emite05;		

create procedure "informix".sp_emite05()
returning	varchar(5),
			varchar(200),
			date,
			varchar(10),
			varchar(10),
			smallint,
			varchar(20),
			varchar(1),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			varchar(100),
			varchar(30),
			varchar(10),
			varchar(30),
			varchar(50),
			smallint;


define _cod_agente			varchar(5);
define _nombre              varchar(200);
define _fecha               date;
define _no_remesa           varchar(10);
define _recibo              varchar(10);
define _renglon             smallint;
define _doc_remesa          varchar(20);
define _tipo_mov            varchar(1);
define _monto               dec(16,2);
define _prima_neta          dec(16,2);
define _impuesto            dec(16,2);
define _monto_descontado    dec(16,2);
define _desc_remesa         varchar(100);
define _tipo_remesa         varchar(1);
define _no_poliza			varchar(10);
define _desc_tipo_r         varchar(30);
define _tipo_pago			smallint;
define _tipo_tarjeta		smallint;
define _forma_pago          varchar(30);
define _cod_banco		    char(3);
define _nombre_banco        varchar(50);

	foreach 
		select b.cod_agente,
			   d.nombre,
			   a.fecha, 
			   a.no_remesa, 
			   no_recibo, 
			   renglon, 
			   doc_remesa, 
			   tipo_mov, 
			   monto, 
			   prima_neta, 
			   impuesto, 
			   monto_descontado, 
			   desc_remesa, 
			   tipo_remesa, 
			   a.no_poliza
		  into _cod_agente,		
		       _nombre,         
		       _fecha,           
		       _no_remesa,       
		       _recibo,          
		       _renglon,         
		       _doc_remesa,      
		       _tipo_mov,        
		       _monto,           
		       _prima_neta,      
		       _impuesto,        
		       _monto_descontado,
		       _desc_remesa,     
		       _tipo_remesa,     
		       _no_poliza
		  from cobredet a inner join cobremae c on a.no_remesa = c.no_remesa inner join emipoagt b on a.no_poliza = b.no_poliza inner join agtagent d on b.cod_agente = d.cod_agente
		 where year(a.fecha) = 2020
		   and b.cod_agente in('02587','02630','02802')
		   and tipo_mov in('P','N')
		   and c.actualizado = 1
		order by a.fecha, a.no_remesa,renglon asc

		let _tipo_pago = 0;
		let _tipo_tarjeta = 0;
		let _forma_pago   = "";
		let _nombre_banco = "";
		let _cod_banco    = "";
		
		FOREACH
			select tipo_pago, 
				   tipo_tarjeta,
				   cod_banco
			  into _tipo_pago,
				   _tipo_tarjeta,
				   _cod_banco
			  from cobrepag
			 where no_remesa = trim(_no_remesa)
			exit foreach;
		END FOREACH
		 
		select nombre
		  into _nombre_banco
		  from chqbanco
		 where cod_banco = _cod_banco;
		
		if _tipo_pago <> 4 then
			let _tipo_tarjeta = 0;
		end if
			let _tipo_pago = _tipo_pago + _tipo_tarjeta;
		
		if _tipo_pago = 1 then
			let _forma_pago = "EFECTIVO";
		elif _tipo_pago = 2 then
			let _forma_pago = "CHEQUE";
		elif _tipo_pago = 3 then
			let _forma_pago = "CLAVE";
		elif _tipo_pago = 5 then
			let _forma_pago = "VISA";
		elif _tipo_pago = 6 then
			let _forma_pago = "MASTERCARD";
		elif _tipo_pago = 7 then
			let _forma_pago = "DINER";
		elif _tipo_pago = 8 then
			let _forma_pago = "AMERICAN";
		end if	     
		
		if _tipo_remesa = 'A' then
			let _desc_tipo_r = 'Recibo Automatico';
		end if
		if _tipo_remesa = 'C' then
			let _desc_tipo_r = 'Comprobantes';
		end if
		if _tipo_remesa = 'M' then
			let _desc_tipo_r = 'Recibo Manual';
		end if
			return _cod_agente,		
				   _nombre,         
				   _fecha,           
				   _no_remesa,       
				   _recibo,          
				   _renglon,         
				   _doc_remesa,      
				   _tipo_mov,        
				   _monto,           
				   _prima_neta,      
				   _impuesto,        
				   _monto_descontado,
				   _desc_remesa,     
				   _desc_tipo_r,     
				   _no_poliza,
				   _forma_pago,
				   _nombre_banco,
				   _tipo_pago			   
				   with resume;
	end foreach

end procedure