-- Carta bienvenida y renovacion de poliza
-- Creado    : 28/11/2013 - Autor: Angel Tello
-- SIS v.2.0 - DEIVID, S.A.
drop procedure sp_pro402;
create procedure "informix".sp_pro402(a_poliza char(10), a_endoso char(5))
returning   char(50),		-- v_ramo					 
			char(20),		-- v_poliza
			dec(16,2),		-- v_prima_total
			char(50),		-- v_codformapag
			date,			-- v_vigen_ini
			date,			-- v_vigen_fin
			char(100),		-- v_asegurado
			char(100),		-- v_contratante
			char(10),		-- v_telefono1
			char(10),		-- v_telefono2
			char(50),		-- v_email
			char(50),		-- v_dir_cobro
			integer;		-- v_n_pagos
						
						
--variables de retorno						
define v_contratante	char(100); -- nombre del contratante
define v_asegurado		char(100); -- nombre del asegurado
define v_codformapag	char(50);  -- codigo forma de pago
define v_direccion		char(50);  -- direccion del asegurador
define v_email			char(50);  -- direcion de correro del contratante	
define v_ramo			char(50);  -- codigo ramo de poliza
define v_poliza			char(20);  -- numero de documento
define v_telefono1		char(10);  -- telefono del contratante
define v_telefono2		char(10);  -- celular del contrantante	
define v_prima_total	dec(16,2); -- prima total
define v_n_pagos		integer;   -- cantidad de pagos
define v_vigen_fin		date;	  -- vigencia final	
define v_vigen_ini		date;	  -- vigencia inicial

--variables de ejecucion
define _cod_contratante	char(6); -- codigo del asegurado
define _cod_asegurado	char(6); -- codigo del contratante
define _cod_formapag	char(3); -- codigo de forma de pago
define _cod_ramo		char(3); -- codigo de ramo

set isolation to dirty read;

-- Lectura de Endedmae
select no_documento,
	   prima_bruta,
	   vigencia_inic,
	   vigencia_final,
	   no_pagos
  into v_poliza,
	   v_prima_total,
	   v_vigen_ini,
	   v_vigen_fin,
	   v_n_pagos
  from endedmae
 where no_poliza = a_poliza
   and no_endoso = a_endoso;
  
-- Lectura de emipomae
select cod_ramo,
	   cod_formapag,
	   cod_pagador,     -- contratante
	   cod_contratante  -- asegurado
  into _cod_ramo,
	   _cod_formapag,
	   _cod_contratante,
	   _cod_asegurado
  from emipomae
 where no_poliza = a_poliza;
	
-- Lectura de cliclien, viene del padre emipomae asegurado
select nombre,
	   nvl(telefono1,''),
	   nvl(celular,''),
	   nvl(e_mail,''),
	   nvl(direccion_1,'')
  into v_contratante,   
	   v_telefono1,
	   v_telefono2,
	   v_email,
	   v_direccion	
  from cliclien
 where cod_cliente = _cod_contratante;

	
-- Lectura de cliclien, viene del padre emipomae contratante
select nombre
  into v_asegurado
  from cliclien
 where cod_cliente = _cod_asegurado;	
	
--lectura de prdramo
select nombre
  into v_ramo	
  from prdramo
 where cod_ramo = _cod_ramo;
	
--lectura de cobforpa
--select nombre
select decode(cod_formapag,'003','ELECTRONICO','005','ELECTRONICO','008','CORREDOR','006','VOLUNTARIO','095','REMESA-TALLER',nombre[7,50]) --SOLICITO:ASTANCIO 27/09/17
  into v_codformapag	
  from cobforpa
 where cod_formapag = _cod_formapag;

return	v_ramo,		   
		v_poliza,		   
		v_prima_total,    
		v_codformapag,   
		v_vigen_ini,     
		v_vigen_fin,	   	
		v_asegurado,   -- contratante 
		v_contratante, -- asegurado
		v_telefono1,     
		v_telefono2,	   	
		v_email,         	
		v_direccion,
		v_n_pagos	
		with resume;
end procedure;