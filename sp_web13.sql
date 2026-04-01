-- Obtener el listado de las polizas de un corredor para reporte en excel Tecnica de seguros pagina web.

-- Creado    : 05/06/2012 - Autor: Federico Coronado

-- SIS - Pagina Web listado de polizas endoso 00000

drop procedure sp_web13;

create procedure "informix".sp_web13(a_cod_corredor char(5), a_fecha_inicial date, a_fecha_final date, a_cod_ramo char(3))
returning char(15),
date,
date,
char(10),
varchar(30),
varchar(20),
char(5),
decimal(10,2),
decimal(10,2),
decimal(10,2),
decimal(10,2),
decimal(10,2),
integer,
varchar(30),
varchar(60),
integer,
char(5),
date;

define _fecha date;
define _no_documento char(15);
define _cedula varchar(30);
define _nombre varchar(60);
define _vigencia_inic date;
define _vigencia_final date;
define _fecha_emision date;
define _nueva_renov char(10);
define _cod_ramo char(3);
define _cod_subramo char(3);
define _no_endoso char(5);
define _no_poliza char(5);

define _nombre_ramo varchar(30);
define _nombre_subramo varchar(20);

define _cod_contratante char(5);
define _prima_bruta decimal(10,2);
define _descuento decimal(10,2);
define _impuesto decimal(10,2);
define _prima_neta decimal(10,2);
define _prima decimal(10,2);
define _no_pagos integer;
define _dia_pago integer;


/*let _fecha   = today;
let _fecha   = _fecha - 3 units month;
let _periodo = sp_sis39(_fecha);*/


set isolation to dirty read;
/*SET DEBUG FILE TO "sp_web13.trc";
TRACE ON;*/   


	foreach

                   select emipomae.no_documento,
						  vigencia_inic,
                          vigencia_final,
                          nueva_renov,
                          cod_ramo,
                          cod_subramo,
                          cod_contratante,
                          prima_bruta,
                          descuento,
                          impuesto,
                          prima_neta,
                          prima,
                          no_pagos,
                          cedula,
                          nombre,
                          emipomae.dia_cobros1,
                          emipomae.no_poliza,
                          fecha_suscripcion
                  into    _no_documento,
						  _vigencia_inic,
			              _vigencia_final,
			              _nueva_renov,
			              _cod_ramo,
			              _cod_subramo,
			              _cod_contratante,
			              _prima_bruta,
			              _descuento,
			              _impuesto,
			              _prima_neta,
			              _prima,
			              _no_pagos,
                          _cedula,
                          _nombre,
						  _dia_pago,
						  _no_poliza,
						  _fecha_emision
                  from emipomae inner join emipoagt on emipomae.no_poliza = emipoagt.no_poliza
                  inner join cliclien on cod_contratante = cod_cliente
                  where cod_agente = a_cod_corredor
				  and cod_ramo = a_cod_ramo
                  and fecha_suscripcion  between a_fecha_inicial and a_fecha_final
				  and actualizado = 1
                  order by emipomae.no_poliza, fecha_suscripcion  desc
				
				if _nueva_renov = 'N' then
					let _nueva_renov = 'NUEVA';
				else
					let _nueva_renov = 'RENOVADA';
				end if 
				
				select nombre
				into _nombre_ramo				
				from prdramo 
				where cod_ramo = _cod_ramo;
				
				select nombre
				into _nombre_subramo				
				from prdsubra 
				where cod_ramo = _cod_ramo
				and cod_subramo = _cod_subramo;
				
				
				
		return _no_documento,
  			   _vigencia_inic,
  			   _vigencia_final,
               _nueva_renov,
               _nombre_ramo,
  		 	   _nombre_subramo,
			   _cod_contratante,
               _prima_bruta,
               _descuento,
               _impuesto,
               _prima_neta,
               _prima,
               _no_pagos,
               _cedula,
               _nombre, 
			   _dia_pago,
               _no_poliza,
               _fecha_emision with resume;
        
      end foreach

end procedure