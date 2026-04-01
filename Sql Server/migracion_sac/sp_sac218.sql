-- Reporte de Presupuesto de Gastos
-- Creado    : 17/01/2012 - Autor: Henry Giron
-- execute procedure sp_sac218('2009','11',2,'sac','6000%','*')
drop procedure sp_sac218;
create procedure "informix".sp_sac218(
a_ano 	  char(4), 
a_mes 	  smallint,
a_nivel	  smallint,
a_db      char(18),
a_cta_gts char(12),
a_ccosto  char(3)
) returning char(12),	  -- cuenta
            char(50),	  -- nombre	
		    char(50),	  -- debito	
			dec(16,2),	  -- credito	
			dec(16,2),	  -- saldo		
			dec(16,2),	  -- saldo_ant	
			char(5), 	  -- auxiliar
			char(50),	  -- name_aux	
		    dec(16,2),	  -- ene 	  
		    dec(16,2),	  -- feb 	  
		    dec(16,2),	  -- mar 	  
		    dec(16,2),	  -- abr 	  
		    dec(16,2),	  -- may 	  
		    dec(16,2),	  -- jun 	
			dec(16,2),	  -- jul 	
			dec(16,2),	  -- ago 	
			dec(16,2),	  -- sep 	
			dec(16,2),	  -- oct 	
			dec(16,2),	  -- nov 	
			dec(16,2),	  -- dic 	
			dec(16,2),	  -- total 
			char(50),	  -- compania
			char(20),	  -- cedula 
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
define _name_ccosto   	char(50);

DEFINE _ene 	 		 DECIMAL(16,2);  
DEFINE _feb 	 		 DECIMAL(16,2);
DEFINE _mar 	 		 DECIMAL(16,2);  
DEFINE _abr 	 		 DECIMAL(16,2);  
DEFINE _may 	 		 DECIMAL(16,2);  
DEFINE _jun 	 		 DECIMAL(16,2);
DEFINE _jul 	 		 DECIMAL(16,2);  
DEFINE _ago 	 		 DECIMAL(16,2);  
DEFINE _sep 	 		 DECIMAL(16,2);  
DEFINE _oct 	 		 DECIMAL(16,2);
DEFINE _nov 	 		 DECIMAL(16,2);  
DEFINE _dic 	 		 DECIMAL(16,2);  
DEFINE _total    		 DECIMAL(16,2); 
define _auxiliar	     char(5);
define _name_aux	     char(50);
define _ter_cedula	     char(20);

define _rubro		smallint;
define _cod_tipo	char(12);
define _nombre_tipo	char(50);
define _orden_rubro	smallint;
define _nombre_rubro char(50);

--set debug file to "sp_sac218.trc";

set isolation to dirty read;

let a_db = trim(a_db);
let a_cta_gts = trim(a_cta_gts)||"%";

select cia_nom
  into _compania
  from sigman02
 where cia_bda_codigo = a_db;

-- Siendo imp = importe, pres = presupuesto, porc = pocentaje, ant = anterior, act = actual

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

CREATE TEMP TABLE tmp_auxsac218a (
        cuenta      CHAR(12) DEFAULT "000"   NOT NULL,
        auxiliar    CHAR(5)  DEFAULT "00000" NOT NULL,
		name_aux	CHAR(50) DEFAULT "00000" NOT NULL,
        ene 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        feb 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        mar 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        abr 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        may 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        jun 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        jul 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        ago 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        sep 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        oct 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        nov 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        dic 	  	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        total     	DECIMAL(16,2) DEFAULT 0  NOT NULL,
        ter_cedula  CHAR(20) DEFAULT "000"   NULL,
		rubro		smallint DEFAULT 0  NOT NULL,
        tipo		char(12)) WITH NO LOG;
CREATE INDEX xie01_tmp_auxsac218a ON tmp_auxsac218a(cuenta,auxiliar,rubro,tipo);

execute procedure sp_sac218a(a_ano, a_mes, a_nivel, a_db, a_cta_gts, a_ccosto);


{foreach
 select	tipo, --cuenta,
		trim(nombre_tipo),		--nombre,		
		rubro,	
		trim(nombre_rubro),
		sum(debito),		
		sum(credito),	
		sum(saldo),		
		sum(saldo_ant)
   into	_cuenta,
		_nombre,	  	
		_rubro,	
		_nombre_rubro,
		_debito,	  	
		_credito,	  
		_saldo,		  
		_saldo_ant
   from tmp_gtsprea
  group by 1,2,3,4
  order by 3,1,2,4}

foreach
 select	rubro,	
		trim(nombre_rubro),
		sum(debito),		
		sum(credito),	
		sum(saldo),		
		sum(saldo_ant)
   into	_rubro,	
		_nombre_rubro,
		_debito,	  	
		_credito,	  
		_saldo,		  
		_saldo_ant
   from tmp_gtsprea
  group by 1,2
  order by 1,2

	   LET _ene   = 0;		
	   LET _feb   = 0;		
	   LET _mar   = 0;		
	   LET _abr   = 0;		
	   LET _may   = 0;		
	   LET _jun   = 0;		
	   LET _jul   = 0;		
	   LET _ago   = 0;		
	   LET _sep   = 0;		
	   LET _oct   = 0;		
	   LET _nov   = 0;		
	   LET _dic   = 0;		
	   LET _total = 0;	
	   LET _name_aux = "";	
	   LET _auxiliar = "";	
	   LET _ter_cedula = "";
	   LET _cuenta = '';
	   LET _nombre = '';	
	   LET _cod_tipo = '';

	return _cuenta,
	       _nombre,	
		   _debito,	
		   _credito,	
		   _saldo,		
		   _saldo_ant,		   
		   _auxiliar,
		   _name_aux,	
		   _ene, 		
		   _feb, 	
		   _mar, 	
		   _abr, 	
		   _may, 	
		   _jun, 	
		   _jul, 	
		   _ago, 	
		   _sep, 	
		   _oct, 	
		   _nov, 	
		   _dic, 	 
		   _total,
		   _compania,
		   _ter_cedula,
		   _rubro,	
		   _nombre_rubro			     	  		   		   		   
		   with resume;


			foreach
			 select	auxiliar,  
					name_aux,	
					--tipo,
					sum(ene), 	  
					sum(feb), 	  
					sum(mar), 	  
					sum(abr), 	  
					sum(may), 	  
					sum(jun), 	  
					sum(jul), 	  
					sum(ago), 	  
					sum(sep), 	  
					sum(oct), 	  
					sum(nov), 	  
					sum(dic), 	  
					sum(total),
					trim(ter_cedula)
			   into	_auxiliar,
					_name_aux,	
					--_cod_tipo,
					_ene, 		
					_feb, 	
					_mar, 	
					_abr, 	
					_may, 	
					_jun, 	
					_jul, 	
					_ago, 	
					_sep, 	
					_oct, 	
					_nov, 	
					_dic, 	 
					_total,
					_ter_cedula
			   from tmp_auxsac218a
			   where rubro = _rubro -- _cuenta -- cuenta = _cuenta
               group by 1,2,16			   
			   order by 2,1

--               group by 3,1,2,17			   
--			  order by 3,2,1

					if _total = 0 then 
					   continue foreach;
					end if

				select nombre 
				  into _nombre_tipo 
				  from sac:cgltigas
				 where cod_tipo = _cod_tipo 
				   and rubro    = _rubro; 

				return _cuenta,
				       _nombre,	
					   _debito,	
					   _credito,	
					   _saldo,		
					   _saldo_ant,	
					   _auxiliar,
					   _name_aux,	
					   _ene, 		
					   _feb, 	
					   _mar, 	
					   _abr, 	
					   _may, 	
					   _jun, 	
					   _jul, 	
					   _ago, 	
					   _sep, 	
					   _oct, 	
					   _nov, 	
					   _dic, 	 
					   _total,
					   _compania,
					   _ter_cedula,
					   _rubro,	
					   _nombre_rubro --,
--					   _tipo,
--					   _nombre_tipo	   
					   with resume;

			end foreach

end foreach

--drop table tmp_gtsprea;
--drop table tmp_auxsac218a;

end procedure

		   