-- Procedimiento que elimina un registro dupplicado en wf_autos

drop procedure sp_par270;

create procedure sp_par270(no_cotizacion integer) 
returning integer,
          char(50);

define _wf_autos_acreedornombre			char(50); 
define _wf_autos_actualizado			char(1); 
define _wf_autos_anoauto 				integer; 
define _wf_autos_anosauto 				integer; 
define _wf_autos_apellido1conductor 	char(20); 
define _wf_autos_apellido2conductor 	char(20); 
define _wf_autos_apellidocconductor 	char(20); 
define _wf_autos_capacidad 				integer; 
define _wf_autos_cedulaconductor 		char(20); 
define _wf_autos_codacreedor 			char(5); 
define _wf_autos_codmarca 				char(5); 
define _wf_autos_codmodelo 				char(5); 
define _wf_autos_codtipo 				char(3); 
define _wf_autos_decnuevo 				smallint; 
define _wf_autos_depreano1 				dec(5,2); 
define _wf_autos_depreciacion 			smallint; 
define _wf_autos_depreresto 			dec(5,2); 
define _wf_autos_desctotal 				dec(16,2); 
define _wf_autos_descuentobe 			dec(16,2); 
define _wf_autos_descuentoesp 			dec(16,2); 
define _wf_autos_descuentoflota 		dec(16,2); 
define _wf_autos_impuestos 				dec(16,2); 
define _wf_autos_marca 					char(50); 
define _wf_autos_modelo 				char(50); 
define _wf_autos_nombre1conductor 		char(20); 
define _wf_autos_nombre2conductor 		char(20); 
define _wf_autos_nrochasis 				char(30); 
define _wf_autos_nrocotizacion 			integer; 
define _wf_autos_nromotor 				char(30); 
define _wf_autos_observacion 			char(250); 
define _wf_autos_peso 					char(20); 
define _wf_autos_placa 					char(10); 
define _wf_autos_porcdescbe 			dec(5,2); 
define _wf_autos_porcdescesp 			dec(5,2); 
define _wf_autos_porcdescflota 			dec(5,2); 
define _wf_autos_porcrecargou 			dec(5,2); 
define _wf_autos_recargototal 			dec(16,2); 
define _wf_autos_tipo 					char(50); 
define _wf_autos_totprimaanual 			dec(16,2); 
define _wf_autos_totprimabruta 			dec(16,2); 
define _wf_autos_totprimaneta 			dec(16,2); 
define _wf_autos_unidad 				char(10); 
define _wf_autos_usandocar 				char(1); 
define _wf_autos_valoractual 			dec(16,2); 
define _wf_autos_valororiginal 			dec(16,2); 
define _wf_autos_vin					char(30);

foreach
 select wf_autos.acreedornombre, 
		wf_autos.actualizado, 
		wf_autos.anoauto, 
		wf_autos.anosauto, 
		wf_autos.apellido1conductor, 
		wf_autos.apellido2conductor, 
		wf_autos.apellidocconductor, 
		wf_autos.capacidad, 
		wf_autos.cedulaconductor, 
		wf_autos.codacreedor, 
		wf_autos.codmarca, 
		wf_autos.codmodelo, 
		wf_autos.codtipo, 
		wf_autos.decnuevo, 
		wf_autos.depreano1, 
		wf_autos.depreciacion, 
		wf_autos.depreresto, 
		wf_autos.desctotal, 
		wf_autos.descuentobe, 
		wf_autos.descuentoesp, 
		wf_autos.descuentoflota, 
		wf_autos.impuestos, 
		wf_autos.marca, 
		wf_autos.modelo, 
		wf_autos.nombre1conductor, 
		wf_autos.nombre2conductor, 
		wf_autos.nrochasis, 
		wf_autos.nrocotizacion, 
		wf_autos.nromotor, 
		wf_autos.observacion, 
		wf_autos.peso, 
		wf_autos.placa, 
		wf_autos.porcdescbe, 
		wf_autos.porcdescesp, 
		wf_autos.porcdescflota, 
		wf_autos.porcrecargou, 
		wf_autos.recargototal, 
		wf_autos.tipo, 
		wf_autos.totprimaanual, 
		wf_autos.totprimabruta, 
		wf_autos.totprimaneta, 
		wf_autos.unidad, 
		wf_autos.usandocar, 
		wf_autos.valoractual, 
		wf_autos.valororiginal, 
		wf_autos.vin
   into _wf_autos_acreedornombre, 
		_wf_autos_actualizado, 
		_wf_autos_anoauto, 
		_wf_autos_anosauto, 
		_wf_autos_apellido1conductor, 
		_wf_autos_apellido2conductor, 
		_wf_autos_apellidocconductor, 
		_wf_autos_capacidad, 
		_wf_autos_cedulaconductor, 
		_wf_autos_codacreedor, 
		_wf_autos_codmarca, 
		_wf_autos_codmodelo, 
		_wf_autos_codtipo, 
		_wf_autos_decnuevo, 
		_wf_autos_depreano1, 
		_wf_autos_depreciacion, 
		_wf_autos_depreresto, 
		_wf_autos_desctotal, 
		_wf_autos_descuentobe, 
		_wf_autos_descuentoesp, 
		_wf_autos_descuentoflota, 
		_wf_autos_impuestos, 
		_wf_autos_marca, 
		_wf_autos_modelo, 
		_wf_autos_nombre1conductor, 
		_wf_autos_nombre2conductor, 
		_wf_autos_nrochasis, 
		_wf_autos_nrocotizacion, 
		_wf_autos_nromotor, 
		_wf_autos_observacion, 
		_wf_autos_peso, 
		_wf_autos_placa, 
		_wf_autos_porcdescbe, 
		_wf_autos_porcdescesp, 
		_wf_autos_porcdescflota, 
		_wf_autos_porcrecargou, 
		_wf_autos_recargototal, 
		_wf_autos_tipo, 
		_wf_autos_totprimaanual, 
		_wf_autos_totprimabruta, 
		_wf_autos_totprimaneta, 
		_wf_autos_unidad, 
		_wf_autos_usandocar, 
		_wf_autos_valoractual, 
		_wf_autos_valororiginal, 
		_wf_autos_vin
   from wf_autos
  where nrocotizacion = no_cotizacion

	insert into wf_autos(
	wf_autos.acreedornombre, 
	wf_autos.actualizado, 
	wf_autos.anoauto, 
	wf_autos.anosauto, 
	wf_autos.apellido1conductor, 
	wf_autos.apellido2conductor, 
	wf_autos.apellidocconductor, 
	wf_autos.capacidad, 
	wf_autos.cedulaconductor, 
	wf_autos.codacreedor, 
	wf_autos.codmarca, 
	wf_autos.codmodelo, 
	wf_autos.codtipo, 
	wf_autos.decnuevo, 
	wf_autos.depreano1, 
	wf_autos.depreciacion, 
	wf_autos.depreresto, 
	wf_autos.desctotal, 
	wf_autos.descuentobe, 
	wf_autos.descuentoesp, 
	wf_autos.descuentoflota, 
	wf_autos.impuestos, 
	wf_autos.marca, 
	wf_autos.modelo, 
	wf_autos.nombre1conductor, 
	wf_autos.nombre2conductor, 
	wf_autos.nrochasis, 
	wf_autos.nrocotizacion, 
	wf_autos.nromotor, 
	wf_autos.observacion, 
	wf_autos.peso, 
	wf_autos.placa, 
	wf_autos.porcdescbe, 
	wf_autos.porcdescesp, 
	wf_autos.porcdescflota, 
	wf_autos.porcrecargou, 
	wf_autos.recargototal, 
	wf_autos.tipo, 
	wf_autos.totprimaanual, 
	wf_autos.totprimabruta, 
	wf_autos.totprimaneta, 
	wf_autos.unidad, 
	wf_autos.usandocar, 
	wf_autos.valoractual, 
	wf_autos.valororiginal, 
	wf_autos.vin
	)
	values(
	_wf_autos_acreedornombre, 
	_wf_autos_actualizado, 
	_wf_autos_anoauto, 
	_wf_autos_anosauto, 
	_wf_autos_apellido1conductor, 
	_wf_autos_apellido2conductor, 
	_wf_autos_apellidocconductor, 
	_wf_autos_capacidad, 
	_wf_autos_cedulaconductor, 
	_wf_autos_codacreedor, 
	_wf_autos_codmarca, 
	_wf_autos_codmodelo, 
	_wf_autos_codtipo, 
	_wf_autos_decnuevo, 
	_wf_autos_depreano1, 
	_wf_autos_depreciacion, 
	_wf_autos_depreresto, 
	_wf_autos_desctotal, 
	_wf_autos_descuentobe, 
	_wf_autos_descuentoesp, 
	_wf_autos_descuentoflota, 
	_wf_autos_impuestos, 
	_wf_autos_marca, 
	_wf_autos_modelo, 
	_wf_autos_nombre1conductor, 
	_wf_autos_nombre2conductor, 
	_wf_autos_nrochasis, 
	_wf_autos_nrocotizacion, 
	_wf_autos_nromotor, 
	_wf_autos_observacion, 
	_wf_autos_peso, 
	_wf_autos_placa, 
	_wf_autos_porcdescbe, 
	_wf_autos_porcdescesp, 
	_wf_autos_porcdescflota, 
	_wf_autos_porcrecargou, 
	_wf_autos_recargototal, 
	_wf_autos_tipo, 
	_wf_autos_totprimaanual, 
	_wf_autos_totprimabruta, 
	_wf_autos_totprimaneta, 
	"002", 
	_wf_autos_usandocar, 
	_wf_autos_valoractual, 
	_wf_autos_valororiginal, 
	_wf_autos_vin
	);

	exit foreach;

end foreach

return 0, "Actualizacion Exitosa";

end procedure