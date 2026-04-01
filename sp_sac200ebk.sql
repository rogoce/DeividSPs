-- Reporte de Presupuesto de Gastos
-- Creado    : 17/01/2012 - Autor: Henry Giron
-- execute procedure sp_sac200e('2012','01',2,'sac','6000%','*')

drop procedure sp_sac200ebk;
create procedure "informix".sp_sac200ebk(
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
			dec(16,2),	  -- porc_alanio  
			char(3),	  -- ccosto
			char(50),	  -- nombre ccosto
			smallint,     -- rubro
			char(50);	  -- nombre rubro

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
define _ccosto   	char(3);
define _name_ccosto char(50);

define _rubro		smallint;
define _cod_tipo	char(12);
define _nombre_tipo	char(50);
define _orden_rubro	smallint;
define _nombre_rubro char(50);
	

set isolation to dirty read;

let a_db = trim(a_db);
let a_cta_gts = trim(a_cta_gts)||"%";

select cia_nom
  into _compania
  from sigman02
 where cia_bda_codigo = a_db;

-- siendo imp = importe, pres = presupuesto, porc = pocentaje, ant = anterior, act = actual
create temp table tmp_gtsprea(
cuenta		char(12),			
ccosto		char(3),
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
porc_alanio	dec(16,2),
rubro		smallint,
tipo		char(12),
nombre_tipo	char(50),
nombre_rubro char(50)	
) with no log;

execute procedure sp_sac220bk(a_ano, a_mes, a_nivel, a_db, a_cta_gts, a_ccosto);
--set debug file to "sp_sac200.trc";
--trace on;

if a_ccosto = '*' then

foreach
 select	tipo, --cuenta,
		nombre_tipo, --nombre,		
		rubro,	
		nombre_rubro,
		sum(debito),		
		sum(credito),	
		sum(saldo),		
		sum(saldo_ant),
		sum(saldo_act),
		--referencia,
		sum(pres_monto),
		sum(imp_delmes),  	
		sum(porc_delmes), 	
		sum(saldo_almes), 
		sum(pres_almes),  	
		sum(imp_almes),	  
		sum(porc_almes),	
		sum(pres_alanio),  
		sum(imp_alanio),	
		sum(porc_alanio)
   into	_cuenta,
		_nombre,	  	
		_rubro,	
		_nombre_rubro,
		_debito,	  	
		_credito,	  
		_saldo,		  
		_saldo_ant,	  
		_saldo_act,	  
		--_referencia,  
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
   from tmp_gtsprea
  group by 1,2,3,4 --,10
  order by 3,1,2,4 --,1

	let _tipo       = _cuenta[1,1];
	let _cuenta_may = _rubro; --_cuenta; --_cuenta[1,3];

	let _ccosto = "*";
	let _name_ccosto = "Todos";
	let _referencia = "";

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
		   _porc_alanio,
		   _ccosto,
		   _name_ccosto,
		   _rubro,	
		   _nombre_rubro	
		   with resume;

end foreach

end if

foreach
 select	tipo, --cuenta,
		ccosto,
		nombre_tipo, --nombre,		
		rubro,	
		nombre_rubro,
		sum(debito),		
		sum(credito),	
		sum(saldo),		
		sum(saldo_ant),
		sum(saldo_act),
		--referencia,
		sum(pres_monto),
		sum(imp_delmes),  	
		sum(porc_delmes), 	
		sum(saldo_almes), 
		sum(pres_almes),  	
		sum(imp_almes),	  
		sum(porc_almes),	
		sum(pres_alanio),  
		sum(imp_alanio),	
		sum(porc_alanio)
   into	_cuenta,	  
        _ccosto,
		_nombre,	  	
		_rubro,	
		_nombre_rubro,
		_debito,	  	
		_credito,	  
		_saldo,		  
		_saldo_ant,	  
		_saldo_act,	  
		--_referencia,  
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
   from tmp_gtsprea
  where ccosto matches a_ccosto
  group by 1,2,3,4,5
  order by 2,4,1,3

--  order by 2,4,3,1

	let _tipo       = _cuenta[1,1];
	let _cuenta_may = _cuenta[1,3];
	let _cuenta_may = _rubro; --_cuenta; --_cuenta[1,3];
	let _referencia = "";

	 if a_db = "sac" then
		 select trim(cen_descripcion) 
		   into _name_ccosto
		   from sac:cglcentro 
		  where cen_codigo = _ccosto;
	  else
		 select trim(cen_descripcion) 
		   into _name_ccosto
		   from cglcentro 
		  where cen_codigo = _ccosto;
	end if

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
		   _porc_alanio,
		   _ccosto,
		   _name_ccosto,
		   _rubro,	
		   _nombre_rubro	
		   with resume;

end foreach

drop table tmp_gtsprea;

end procedure

			