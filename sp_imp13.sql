-- Procedimiento que Realiza la Carga a la tabla emivesoda

-- Creado    : 21/02/2013

drop procedure sp_imp13;

create procedure "informix".sp_imp13(a_no_poliza char(8))
RETURNING INTEGER;

define _no_poliza    char(10);   
define _no_unidad    char(5);  
define _cod_tipoveh  char(3);
define _no_motor     varCHAR(50);  
define _uso_auto     char(1);
define _ano_tarifa   smallint;
define _cod_color    char(3);
define _cod_marca    char(5);
define _cod_modelo   char(5);
define _valor_auto   DEC(16,2);
define _valor_original DEC(16,2); 
define _ano_auto       integer;
define _no_chasis   char(50);
define _vin         char(50);
define _placa       char(30);
define _placa_taxi  char(30);
define _nuevo       smallint;
define _user_added  char(10);   
define _date_added  date; 
define _user_changed char(10);
define _date_changed date;  
define _desc_unidad  char(50);  
define _cod_ruta     char(5);
define _cod_producto  char(5);   
define _cod_asegurado char(10);
define _suma_asegurada DEC(16,2);  
define _perd_total      smallint;   
define _cod_agente      char(8);
define _porc_partic_agt DEC(5,2); 
define _porc_comis_agt  DEC(5,2);
define _porc_produc     DEC(5,2);  
define _no_pagos		smallint;
define _error smallint;

--SET DEBUG FILE TO "sp_imp13.trc"; 
--trace on;

SET LOCK MODE TO WAIT;

select cod_tipoveh,
       no_motor,
       uso_auto,
       ano_tarifa
into _cod_tipoveh,
	 _no_motor,
	 _uso_auto,
	 _ano_tarifa
from emiauto
where no_poliza = a_no_poliza;

select no_poliza,
	no_unidad,
	desc_unidad,
	cod_ruta,
	cod_producto,
	cod_asegurado,
	suma_asegurada,
	no_pagos
into _no_poliza,
	 _no_unidad,
	 _desc_unidad,
	 _cod_ruta,
	 _cod_producto,
	 _cod_asegurado,
	 _suma_asegurada,
	 _no_pagos
from emipouni
where no_poliza = a_no_poliza;

select cod_agente, 
	   porc_partic_agt, 
	   porc_comis_agt, 
	   porc_produc
into   _cod_agente, 
	   _porc_partic_agt, 
	   _porc_comis_agt, 
	   _porc_produc   
from   emipoagt 
where no_poliza = a_no_poliza;

if _no_motor is not null AND TRIM(_no_motor) <> "" Then -- Habra cotizaciones sin valor del automovil
	select
	no_motor,
	cod_color,
	cod_marca,
	cod_modelo,
	valor_auto,		
	valor_original,
	ano_auto,		
	no_chasis,		
	vin,
	placa,
	placa_taxi,    
	nuevo,			
	user_added,		
	date_added,		
	user_changed
	into _no_motor,		 -- no_motor
		 _cod_color,	 -- cod_color
	     _cod_marca,		 -- cod_marca
	     _cod_modelo,     -- cod_modelo
	     _valor_auto,	 -- valor_auto		0
	     _valor_original, -- valor_original	0
	     _ano_auto,		 -- ano_auto		null
	     _no_chasis,	 -- no_chasis		null
	     _vin,			 -- vin
	     _placa,		 -- placa
	     _placa_taxi,	 -- placa_taxi      null
		 _nuevo,		 -- nuevo			1
		 _user_added,    -- user_added		convers
	     _date_added,	 -- date_added		today
		 _user_changed	 -- user_changed	null
	from emivehic
	where no_poliza = _no_motor;
else
let _cod_color = '';
let _cod_marca = '';
let _cod_modelo = '';
let _valor_auto = 0;
let _valor_original = 0;
let _ano_auto = 0;
let _no_chasis = '';
let _vin = '';
let _placa = '';
let _placa_taxi = '';
let _nuevo = 0;
let _user_added = '';
let _date_added = '';
let _user_changed = '';
let _cod_tipoveh = '013';
let _no_motor = ' ';
let _uso_auto = ' ';
let _ano_tarifa = 0;
let _date_added = today;	
insert into emivesoda(
		 no_poliza,   
         no_unidad,   
         cod_tipoveh,   
         no_motor,   
         uso_auto,   
         ano_tarifa,   
         cod_color,   
         cod_marca,   
         cod_modelo,   
         valor_auto,   
         valor_original,   
         ano_auto,   
         no_chasis,   
         vin,   
         placa,   
         placa_taxi,   
         nuevo,   
         user_added,   
         date_added,   
         user_changed,   
         date_changed,   
         desc_unidad,   
         cod_ruta,   
         cod_producto,   
         cod_asegurado,   
         suma_asegurada,   
         perd_total,   
         cod_agente,   
         porc_partic_agt,   
         porc_comis_agt,   
         porc_produc,   
         no_pagos
		 )
values (
		 _no_poliza,   
         _no_unidad,   
         _cod_tipoveh,   
         _no_motor,   
         _uso_auto,   
         _ano_tarifa,   
         _cod_color,   
         _cod_marca,   
         _cod_modelo,   
         _valor_auto,   
         _valor_original,   
         _ano_auto,   
         _no_chasis,   
         _vin,   
         _placa,   
         _placa_taxi,   
         _nuevo,   
         _user_added,   
         _date_added,   
         _user_changed,   
         '',   
         _desc_unidad,   
         _cod_ruta,   
         _cod_producto,   
         _cod_asegurado,   
         _suma_asegurada,   
         0,   
         _cod_agente,   
         _porc_partic_agt,   
         _porc_comis_agt,   
         _porc_produc,   
         _no_pagos
);
end if
RETURN 0;	
end procedure;