-- Obtener el listado de los recibos de págos de un corredor para reporte en excel Tecnica de seguros pagina web.

-- Creado    : 27/06/2012 - Autor: Federico Coronado

-- SIS - Pagina Web

drop procedure sp_web14;

create procedure "informix".sp_web14(a_cod_corredor char(5), a_fecha_inicial date, a_fecha_final date)
returning char(15),
date,
char(15),
char(30),
char(60),
char(30),
char(20),
char(30),
decimal(10,2),
char(15),
char(20),
char(30),
char(15),
char(10),
integer;

define _no_recibo char(15);
define _no_remesa char(15);
define _fecha_pago date;
define _no_documento char(15);
define _no_poliza char(10);
define _doc_remesa char(15);
define _cod_contratante char(10);
define _cedula char(30);
define _nombre char(60);
define _no_cheque char(15);
define _cod_banco char(15);
define _no_renglon char(15);
define _nombre_ramo char(30);
define _nombre_subramo char(20);
define _nombre_banco char(20);
define _nombre_tipo_pago char(30);

define _lugar_pago_remesa char(30);
define _no_recibo_cobpaex0 char(10);

define _vigencia_inic date;
define _vigencia_final date;

define _monto decimal(10,2);

define _tipo_pago integer;
define _tipo_tarjeta integer;
define _cantidad integer;
define _no_lugar_pago integer;

define _cod_ramo char(3);
define _cod_subramo char(3);

/*let _fecha   = today;
let _fecha   = _fecha - 3 units month;
let _periodo = sp_sis39(_fecha);*/


set isolation to dirty read;
/*SET DEBUG FILE TO "sp_web14.trc";
TRACE ON;*/
		foreach
					/*select  cobredet.no_recibo,
							cobremae.fecha,
							cobredet.no_poliza,
							doc_remesa,
							cobredet.no_remesa,
							monto,
							cobredet.renglon
					into _no_recibo,
						 _fecha_pago,
						 _no_poliza,
						 _doc_remesa,
						 _no_remesa,
						 _monto,
						 _no_renglon
					from cobreagt inner join cobremae on cobreagt.no_remesa = cobremae.no_remesa
					inner join cobredet on cobredet.no_remesa = cobremae.no_remesa
					inner join emipoagt on emipoagt.no_poliza = cobredet.no_poliza
					inner join emipomae on emipomae.no_poliza = cobredet.no_poliza
					where cobreagt.cod_agente = a_cod_corredor and emipoagt.cod_agente = a_cod_corredor
					and cobremae.fecha between a_fecha_inicial and a_fecha_final
					and cod_ramo = '016'
					and tipo_mov in('P','N')
					and cobremae.actualizado = 1
					and cobredet.actualizado = 1
					group by 1,2,3,4,5,6,7
					order by no_recibo, no_poliza*/
					select a.no_remesa,
					       fecha
					  into _no_remesa,
						   _fecha_pago
					  from cobremae a
			    inner join cobreagt b on a.no_remesa = b.no_remesa
					 where b.cod_agente = a_cod_corredor
                       and a.fecha between a_fecha_inicial and a_fecha_final
                  group by 1,2
			foreach
				  select a.no_poliza, 
						 a.no_recibo, 
						 doc_remesa, 
						 monto, 
						 renglon 
					into  _no_poliza,
						  _no_recibo,
						  _doc_remesa,
						  _monto,
						 _no_renglon
				    from cobredet a inner join emipomae b on a.no_poliza = b.no_poliza
                   where no_remesa = _no_remesa
                     and cod_ramo = '016'

					select cod_contratante,
						   no_documento,
						   cod_ramo,
						   cod_subramo
					into _cod_contratante,
					     _no_documento,
						 _cod_ramo,
						 _cod_subramo
					from emipomae
					where no_poliza = _no_poliza;
					
					select cedula, 
						   nombre
					into _cedula,
						 _nombre
					from cliclien
					where cod_cliente = _cod_contratante;
					
					select nombre
					into _nombre_ramo				
					from prdramo 
					where cod_ramo = _cod_ramo;
					
					select nombre
					into _nombre_subramo				
					from prdsubra 
					where cod_ramo = _cod_ramo
					and cod_subramo = _cod_subramo;
					
					let _nombre_tipo_pago = " ";
					let _nombre_banco = " ";
					let _nombre_tipo_pago = " ";
					let _tipo_pago = 0;
					let _no_cheque = " ";
					let _tipo_tarjeta = 0;
					let _no_recibo_cobpaex0 = " ";
					
					select count(*)
					into _cantidad
					from cobrepag 
					where no_remesa = _no_remesa
					and renglon = _no_renglon;
					
						if _cantidad > 0 then
							select no_cheque, 
								   cod_banco,
								   tipo_pago,
								   tipo_tarjeta
							into _no_cheque,
								 _cod_banco,
								 _tipo_pago,
								 _tipo_tarjeta
							from cobrepag 
							where no_remesa = _no_remesa
							and renglon = _no_renglon;
							
							select nombre
							into _nombre_banco
							from chqbanco 
							where cod_banco = _cod_banco;
						end if
					
					if _tipo_pago = 1 or _tipo_pago = 0 then
						let _nombre_tipo_pago = "Efectivo";
					elif _tipo_pago = 2 then
						let _nombre_tipo_pago = "Cheque";
					elif _tipo_pago = 3 then
						let _nombre_tipo_pago = "Clave";
					elif _tipo_pago = 4 then
						if _tipo_tarjeta = 1 then
						   let _nombre_tipo_pago = "Tarjeta de Credito Visa";
						elif _tipo_tarjeta = 2 then
						   let _nombre_tipo_pago = "Tarjeta de Credito MasterCard";
						elif _tipo_tarjeta = 3 then
							let _nombre_tipo_pago = "Tarjeta de Credito Dinners Club";
						elif _tipo_tarjeta = 4 then
							let _nombre_tipo_pago = "Tarjeta de Credito American Express";
						end if
					end if
					
					select count(*)
					into _no_lugar_pago
					from cobpaex0 
					where no_remesa_ancon = _no_remesa
					and cod_agente = a_cod_corredor;
					
					if _no_lugar_pago > 0 then
						select no_remesa
						into _no_recibo_cobpaex0
						from cobpaex0 
						where no_remesa_ancon = _no_remesa
						and cod_agente = a_cod_corredor;
						let _lugar_pago_remesa = "Tecnica de Seguros";
					else
						let _lugar_pago_remesa = "Aseguradora Ancon";
					end if
					
						   return _no_recibo,            --1
								  _fecha_pago,           --2
								  _no_documento,         --3
								  _cedula,               --4
								  _nombre,               --5
								  _nombre_ramo,          --6
								  _nombre_subramo,       --7
								  _nombre_tipo_pago,     --8
								  _monto,                --9
								  _no_cheque,           --10
								  _nombre_banco,        --11
								  _lugar_pago_remesa,   --12
								  _no_remesa,           --13
								  _no_recibo_cobpaex0,  --14
								  _tipo_pago with resume; --15
				end foreach
		end foreach
end procedure