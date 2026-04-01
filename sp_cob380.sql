--Procedimiento para sacar las pólizas de Avisocanc que no tienen estatus Y, Z y que no tienen marcado el carta_aviso_can en emipomae

DROP PROCEDURE sp_cob380;
CREATE PROCEDURE sp_cob380()
RETURNING smallint, CHAR(10), CHAR(10), CHAR(20), CHAR(100), date, CHAR(10), CHAR(10), VARCHAR(200), CHAR(9),smallint, date, smallint;

Define _no_documento		 char(20);
Define _no_poliza			 char(10);
Define _usuario1        	 char(10);
Define _usuario2        	 char(10);
define _estatus_poliza_c     char(9);
define _fecha_aviso_canc     date;
define _carta_aviso_canc     smallint;
define _renglon				 smallint;
define _no_aviso             char(10);
define _nombre_cliente       char(100);
define _fecha_imprimir       date;
define _estatus				 char(1);
define _estatus_poliza		 char(1);
define _estatus_c			 varchar(200);
define _carta_prima_gan      smallint;


--set debug file to "sp_cob757.trc";
--trace on;

set isolation to dirty read;

foreach
select renglon,
       no_aviso,
       no_poliza,
       no_documento,
       nombre_cliente,
       fecha_imprimir,
       usuario1,
       usuario2,
       estatus
  into _renglon,
       _no_aviso,
       _no_poliza,
       _no_documento,
       _nombre_cliente,
       _fecha_imprimir,
       _usuario1,
       _usuario2,
       _estatus
from avisocanc
where estatus not in ('Y','Z','W')
order by no_aviso,no_poliza

select estatus_poliza,
       carta_prima_gan
  into _estatus_poliza,
       _carta_prima_gan
  from emipomae
 where actualizado = 1
   and no_poliza = _no_poliza; 

if _estatus_poliza = 1 then
	let _estatus_poliza_c = 'VIGENTE';
elif _estatus_poliza = 2 then
	let _estatus_poliza_c = 'CANCELADA';
elif _estatus_poliza = 3 then
	let _estatus_poliza_c = 'VENCIDA';
else
	let _estatus_poliza_c = 'ANULADA';
end if

if _estatus = 'G' then
	let _estatus_c = 'G: Proceso Inicial: estatus inicial cuando la campana ha sido activada pero no se ha generado el aviso de cancelacion.';
elif _estatus = 'R' then
	let _estatus_c = 'R: Clasificar(Email, Estafeta, Otros): es un estatus interno que se genera al momento de procesar los avisos de cancelacion, la poliza fue procesada pero no fue generado el aviso de cancelacion.';
elif _estatus = 'I' then
	let _estatus_c = 'I: Imprimir y Enviar: el aviso de cancelacion fue generado, impreso y enviado por correo electronico, si aplica, y esta a la espera de ingresar la fecha de entregado por correo certificado.';
elif _estatus = 'M' then
	let _estatus_c = 'M: Marcar Aviso: en este estatus el aviso de cancelacion fue marcado como entregado y solo esta a la espera de que pasen los días estipulados para pasar al estatus X (por Cancelar)';
elif _estatus = 'X' then
	let _estatus_c = 'X: Procesar a Quince dias: en este estatus han transcurrido los dias estipulados para cancelar la poliza y solo queda a la espera de que el supervisor ejecute el proceso de cancelacion.';
end if
	
select carta_aviso_canc,
       fecha_aviso_canc
  into _carta_aviso_canc,
       _fecha_aviso_canc
  from emipomae
 where no_poliza = _no_poliza;
 
	return  _renglon,_no_aviso,_no_poliza,_no_documento,_nombre_cliente,_fecha_imprimir,_usuario1,_usuario2,_estatus_c,_estatus_poliza_c,_carta_aviso_canc,_fecha_aviso_canc,_carta_prima_gan with resume;

end foreach
end procedure
