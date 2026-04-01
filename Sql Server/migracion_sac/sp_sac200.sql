-- Reporte de Presupuesto de Gastos
-- Creado    : 17/01/2012 - Autor: Henry Giron
-- execute procedure sp_sac200('2009','11',2,'sac','6000%','*')

drop procedure sp_sac200;
create procedure "informix".sp_sac200(
a_ano 	  char(4), 
a_mes 	  smallint,
a_nivel	  smallint,
a_db      char(18),
a_cta_gts char(12),
a_ccosto  char(3)
) returning char(2),	  -- tipo		  
            char(12),	  -- cuenta		  
		    char(50),	  -- nombre		  
		    dec(16,2),	  -- debito		  
		    dec(16,2),	  -- credito	  
		    dec(16,2),	  -- saldo		  
		    dec(16,2),	  -- saldo_ant	  
		    dec(16,2),	  -- saldo_act	  
            char(3),	  -- cuenta_may	  
            char(50),	  -- compania	  
            char(20),	  -- referencia	  
		    dec(16,2),	  -- pres_monto	  
			dec(16,2),	  -- imp_delmes	  
			dec(16,2),	  -- porc_delmes  
			dec(16,2),	  -- saldo_almes  
			dec(16,2),	  -- pres_almes	  
			dec(16,2),	  -- imp_almes	  
			dec(16,2),	  -- porc_almes	  
			dec(16,2),	  -- pres_alnio   
			dec(16,2),	  -- imp_alanio	  
			dec(16,2);	  -- porc_alanio  

define _tipo		char(2);
define _cuenta_may	char(3);
define _cuenta		char(12);
define _nombre		char(50);
define _referencia	char(20);
define _pres_monto	dec(16,2);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _saldo		dec(16,2);
define _saldo_ant	dec(16,2);
define _saldo_act	dec(16,2);
define _compania	char(50);
define _imp_delmes	dec(16,2); 
define _porc_delmes	dec(16,2); 
define _saldo_almes	dec(16,2); 
define _pres_almes	dec(16,2); 
define _imp_almes	dec(16,2); 
define _porc_almes	dec(16,2); 
define _pres_alanio dec(16,2); 
define _imp_alanio	dec(16,2); 
define _porc_alanio	dec(16,2); 

set isolation to dirty read;

let a_db = trim(a_db);
let a_cta_gts = trim(a_cta_gts)||"%";

select cia_nom
  into _compania
  from sigman02
 where cia_bda_codigo = a_db;

--siendo imp = importe, pres = presupuesto, porc = pocentaje, ant = anterior, act = actual
create temp table tmp_gtspre(
cuenta		char(12),			
nombre		char(50),			
debito		dec(16,2),			
credito		dec(16,2),			
saldo		dec(16,2),			
saldo_ant	dec(16,2),			
saldo_act	dec(16,2),			
referencia	char(20),			
pres_monto	dec(16,2),			
imp_delmes	dec(16,2),			
porc_delmes	dec(16,2),			
saldo_almes	dec(16,2),			
pres_almes	dec(16,2),			
imp_almes	dec(16,2),			
porc_almes	dec(16,2),			
pres_alanio dec(16,2),			
imp_alanio	dec(16,2),			
porc_alanio	dec(16,2)			
) with no log;

execute procedure sp_sac201(a_ano, a_mes, a_nivel, a_db, a_cta_gts, a_ccosto);
--set debug file to "sp_sac200.trc";
--trace on;
foreach
 select	cuenta,
		nombre,		
		debito,		
		credito,	
		saldo,		
		saldo_ant,
		saldo_act,
		referencia,
		pres_monto,
		imp_delmes,  	
		porc_delmes, 	
		saldo_almes, 
		pres_almes,  	
		imp_almes,	  
		porc_almes,	
		pres_alanio,  
		imp_alanio,	
		porc_alanio
   into	_cuenta,	  
		_nombre,	  	
		_debito,	  	
		_credito,	  
		_saldo,		  
		_saldo_ant,	  
		_saldo_act,	  
		_referencia,  
		_pres_monto,  
		_imp_delmes,  
		_porc_delmes, 
		_saldo_almes, 
		_pres_almes,  
		_imp_almes,	   
		_porc_almes,  	
		_pres_alanio, 
		_imp_alanio,  	
		_porc_alanio  
   from tmp_gtspre
  order by 1

	let _tipo       = _cuenta[1,1];
	let _cuenta_may = _cuenta[1,3];

	return _tipo,
	       _cuenta,
		   _nombre,
		   _debito,
		   _credito,
		   _saldo,
		   _saldo_ant,
		   _saldo_act,
		   _cuenta_may,
		   _compania,
		   _referencia,
		   _pres_monto,
		   _imp_delmes,	
		   _porc_delmes,	
		   _saldo_almes,	
		   _pres_almes,	
		   _imp_almes,	
		   _porc_almes,	
		   _pres_alanio,  
		   _imp_alanio,	
		   _porc_alanio	
		   with resume;

end foreach

drop table tmp_gtspre;

end procedure