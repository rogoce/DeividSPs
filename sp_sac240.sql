-- Procedure que determina los asientos actuales del nuevo contrato mapfre 50/50

-- Creado    : 22/01/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac240;

create procedure sp_sac240()
returning char(25),
          char(50);

define _periodo			char(7);		  
define v_cuenta			char(25);	
define v_debito     		dec(16,2);
define v_credito    		dec(16,2);
define v_debito_2   		dec(16,2);
define v_credito_2  		dec(16,2);
define v_tipo_comp			smallint;

define _origen      		smallint;
define _cod_auxiliar		char(5);

define _notrx				integer;
define _linea				integer;
define _linea_aux			integer;
define _comprobante		char(20);
define _secuencia			integer;

create temp table tmp_comp_prod_50_50(
origen			 	smallint,
tipo_comprobante 	smallint,
periodo			 	char(7),
cuenta		   	 	char(25),
debito_1      	 	decimal(16,2) default 0,
credito_1	     	decimal(16,2) default 0,
debito_2      		decimal(16,2) default 0,
credito_2	     	decimal(16,2) default 0
) with no log;

create temp table tmp_comp_prod2_50_50(
origen			 	smallint,
tipo_comprobante 	smallint,
periodo			 	char(7),
cuenta		   	 	char(25),
cod_auxiliar	 	char(5),
debito_1      	 	decimal(16,2) default 0,
credito_1	     	decimal(16,2) default 0,
debito_2      	 	decimal(16,2) default 0,
credito_2	     	decimal(16,2) default 0
) with no log;

set isolation to dirty read;

-- Cuentas

foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        sum(debito), 
        sum(credito)
   into _periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        v_debito, 
        v_credito
   from deivid:tmp_prod_50_50
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	insert into tmp_comp_prod_50_50(
	origen,
	tipo_comprobante,
	periodo,
	cuenta,   
	debito_1,	  
    credito_1
	)
	values(
	_origen,
	v_tipo_comp,
	_periodo,
	v_cuenta,  
	v_debito,
	v_credito
	);

end foreach

foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        sum(debito), 
        sum(credito)
   into _periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        v_debito, 
        v_credito
   from deivid_tmp:tmp_prod_50_50
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	insert into tmp_comp_prod_50_50(
	origen,
	tipo_comprobante,
	periodo,
	cuenta,   
	debito_2,	  
    credito_2
	)
	values(
	_origen,
	v_tipo_comp,
	_periodo,
	v_cuenta,  
	v_debito,
	v_credito
	);

end foreach

-- Auxiliares
--{
foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        cod_auxiliar,
        sum(debito),
		sum(credito)
   into	_periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        _cod_auxiliar,
        v_debito,
		v_credito
   from deivid:tmp_prod2_50_50 
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	insert into tmp_comp_prod2_50_50(
	origen,
	tipo_comprobante,
	periodo,
	cuenta,
	cod_auxiliar,   
	debito_1,	  
    credito_1
	)
	values(
	_origen,
	v_tipo_comp,
	_periodo,
	v_cuenta,
	_cod_auxiliar,  
	v_debito,
	v_credito
	);

end foreach

foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        cod_auxiliar,
        sum(debito),
		sum(credito)
   into	_periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        _cod_auxiliar,
        v_debito,
		v_credito
   from deivid_tmp:tmp_prod2_50_50 
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	insert into tmp_comp_prod2_50_50(
	origen,
	tipo_comprobante,
	periodo,
	cuenta,
	cod_auxiliar,   
	debito_2,	  
    credito_2
	)
	values(
	_origen,
	v_tipo_comp,
	_periodo,
	v_cuenta,
	_cod_auxiliar,  
	v_debito,
	v_credito
	);

end foreach

--}
-- Asiento de Reversion

let _notrx     = sp_sac10();
let _secuencia	= sp_sac151(2015, "09");

if _secuencia > 9999 then
	let _comprobante = "09-" || _secuencia;
elif _secuencia > 999 then
	let _comprobante = "09-0" || _secuencia;
elif _secuencia > 99 then
	let _comprobante = "09-00" || _secuencia;
elif _secuencia > 9 then
	let _comprobante = "09-000" || _secuencia;
else
	let _comprobante = "09-0000" || _secuencia;
end if

-- Insercion de Comprobantes

insert into cgltrx1(
trx1_notrx,
trx1_tipo,
trx1_comprobante,
trx1_fecha,
trx1_concepto,
trx1_ccosto,
trx1_descrip,
trx1_monto,
trx1_moneda,
trx1_debito,
trx1_credito,
trx1_status,
trx1_origen,
trx1_usuario,
trx1_fechacap
)
values(
_notrx,
"01",
_comprobante,
Today,
"011",
"001",
"ELIMINACION SWISS RE DE LOS CONTRATOS",
0.00,
"00",
0.00,
0.00,
"I",
"CGL",
"DEIVID",
Today
);

let _linea = 0;

foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        sum(debito_1), 
        sum(credito_1)
   into _periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        v_debito, 
        v_credito
   from tmp_comp_prod_50_50
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	let _linea = _linea + 1;
	
	insert into cgltrx2(
	trx2_notrx,
	trx2_tipo,
	trx2_linea,
	trx2_cuenta,
	trx2_ccosto,
	trx2_debito,
	trx2_credito,
	trx2_actlzdo
	)
	values(
	_notrx,
	"01",
	_linea,
	v_cuenta,
	"001",
	v_credito,
	v_debito,
	0
	);

	let _linea_aux = 0;
	
	foreach
	 select cod_auxiliar,
	        sum(debito_1),
			sum(credito_1)
	   into	_cod_auxiliar,
	        v_debito,
			v_credito
	   from tmp_comp_prod2_50_50 
	  where	origen			 	= _origen
        and tipo_comprobante	= v_tipo_comp
        and periodo			= _periodo
        and cuenta		   	 	= v_cuenta
	  group by cod_auxiliar

			let _linea_aux = _linea_aux + 1;
	  
			insert into cgltrx3(
			trx3_notrx,
			trx3_tipo,
			trx3_lineatrx2,
			trx3_linea,
			trx3_cuenta,
			trx3_auxiliar,
			trx3_debito,
			trx3_credito,
			trx3_actlzdo
			)
			values(
			_notrx,
			"01",
			_linea,
			_linea_aux,
			v_cuenta,
			_cod_auxiliar,
			v_credito,
			v_debito,
			0
			);
	  	  
	end foreach

end foreach

return _notrx,	_comprobante with resume;
--}

--{  
-- Asiento de Constitucion

let _notrx     = sp_sac10();
let _secuencia	= sp_sac151(2015, "09");

if _secuencia > 9999 then
	let _comprobante = "09-" || _secuencia;
elif _secuencia > 999 then
	let _comprobante = "09-0" || _secuencia;
elif _secuencia > 99 then
	let _comprobante = "09-00" || _secuencia;
elif _secuencia > 9 then
	let _comprobante = "09-000" || _secuencia;
else
	let _comprobante = "09-0000" || _secuencia;
end if

-- Insercion de Comprobantes

insert into cgltrx1(
trx1_notrx,
trx1_tipo,
trx1_comprobante,
trx1_fecha,
trx1_concepto,
trx1_ccosto,
trx1_descrip,
trx1_monto,
trx1_moneda,
trx1_debito,
trx1_credito,
trx1_status,
trx1_origen,
trx1_usuario,
trx1_fechacap
)
values(
_notrx,
"01",
_comprobante,
Today,
"011",
"001",
"INCLUSION DE AON RE A LOS CONTRATOS",
0.00,
"00",
0.00,
0.00,
"I",
"CGL",
"DEIVID",
Today
);

let _linea = 0;

foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        sum(debito_2), 
        sum(credito_2)
   into _periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        v_debito_2, 
        v_credito_2
   from tmp_comp_prod_50_50
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	let _linea = _linea + 1;
	
	insert into cgltrx2(
	trx2_notrx,
	trx2_tipo,
	trx2_linea,
	trx2_cuenta,
	trx2_ccosto,
	trx2_debito,
	trx2_credito,
	trx2_actlzdo
	)
	values(
	_notrx,
	"01",
	_linea,
	v_cuenta,
	"001",
	v_debito_2,
	v_credito_2,
	0
	);

	let _linea_aux = 0;
	
	foreach
	 select cod_auxiliar,
	        sum(debito_2),
			sum(credito_2)
	   into	_cod_auxiliar,
	        v_debito_2,
			v_credito_2
	   from tmp_comp_prod2_50_50 
	  where	origen			 	= _origen
        and tipo_comprobante	= v_tipo_comp
        and periodo		 	= _periodo
        and cuenta		   	 	= v_cuenta
	  group by cod_auxiliar

			let _linea_aux = _linea_aux + 1;
	  
			insert into cgltrx3(
			trx3_notrx,
			trx3_tipo,
			trx3_lineatrx2,
			trx3_linea,
			trx3_cuenta,
			trx3_auxiliar,
			trx3_debito,
			trx3_credito,
			trx3_actlzdo
			)
			values(
			_notrx,
			"01",
			_linea,
			_linea_aux,
			v_cuenta,
			_cod_auxiliar,
			v_debito_2,
			v_credito_2,
			0
			);
	  
	end foreach

end foreach

return _notrx,	_comprobante with resume;
--}

drop table tmp_comp_prod_50_50;
drop table tmp_comp_prod2_50_50;

end procedure 