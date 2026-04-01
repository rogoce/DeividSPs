-- Procedure que verifica si es posible perdida total													   
-- Creado por: Amado Perez 05/05/2015

drop procedure sp_rwf137;

create procedure sp_rwf137(a_no_reclamo char(10), a_mano_obra dec(16,2), a_piezas dec(16,2))
returning dec(16,2), varchar(50);

define _no_documento    char(20);
define _no_poliza       char(10);
define _no_unidad       char(5);
define _suma_asegurada  dec(16,2);
define _no_motor        char(30);
define _fecha_siniestro, _vigencia_inic date;
define _vig_ch          char(10);
define _vig_ano         integer;
define _uso_auto        char(1);
define _ano_auto        integer;
define _anos            smallint;
define _porc_depre      smallint;
define _depre_anual     dec(16,2);
define _depre_mensual   dec(16,2);
define _depre_diario    dec(16,2);
define _dias            integer;
define _perdida         dec(16,2);
define _pagos_tot       dec(16,2);
define _pagos           dec(16,2);
define _no_tranrec      char(10);
define _porc_perdida    dec(16,2);

define _error           integer;
define _descripcion		varchar(50);
define _monto           dec(16,2);
define _retorno         integer;

define _cod_ramo        char(3);

if a_no_reclamo = '627673' then
 -- SET DEBUG FILE TO "sp_rwf137.trc"; 
 -- TRACE ON; 
end if                                                               
set isolation to dirty read;

begin

ON EXCEPTION SET _error 
 	RETURN _error, "Error al buscar las piezas";         
END EXCEPTION

let _error = 0;
let _retorno = 0;

let _descripcion = "Verificacion exitosa";

select no_documento, 
       no_poliza, 
	   no_unidad,
	   suma_asegurada,
	   no_motor,
	   fecha_siniestro
  into _no_documento,
       _no_poliza, 
	   _no_unidad,
	   _suma_asegurada,
	   _no_motor,
	   _fecha_siniestro
  from recrcmae
 where no_reclamo = a_no_reclamo;
 
--let _saldo = sp_rwf100(_no_documento);

--call sp_rwf101(a_no_reclamo)  returning _cod_cobertura, _deducible;

select vigencia_inic, cod_ramo
  into _vigencia_inic, _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;
 
if _cod_ramo = '020' then
	return 0, '';
end if

let _vig_ch = _vigencia_inic;

let _vig_ano = _vig_ch[7,10];
 
let _uso_auto = null;
 
select uso_auto
  into _uso_auto
  from emiauto
 where no_poliza = _no_poliza
   and no_unidad = _no_unidad;

if  _uso_auto is null  or trim(_uso_auto) = "" then
	select uso_auto
      into _uso_auto
      from endmoaut
     where no_poliza = _no_poliza
       and no_unidad = _no_unidad;
end if

select ano_auto
  into _ano_auto
  from emivehic
 where no_motor = _no_motor;

let _anos = _vig_ano - _ano_auto;

if _anos <= 0 or _anos = 1 then
   let _anos = 1;
else
   let _anos = _anos + 1;
end if

let _porc_depre = 0.00;

select porc_depre
  into _porc_depre
  from emidepre
 where uso_auto = _uso_auto
   and ano_desde <= _anos
   and ano_hasta >= _anos;

let _depre_anual = _suma_asegurada * _porc_depre / 100;
let _depre_mensual = _depre_anual / 12;
let _depre_diario  =  _depre_mensual / 30;
let _dias = (_fecha_siniestro - _vigencia_inic) * -1;
let _perdida = _suma_asegurada + _depre_diario * _dias;

let _pagos_tot = 0.00;
let _porc_perdida = 0.00;

foreach 
  select no_tranrec
    into _no_tranrec
	from rectrmae
   where no_reclamo = a_no_reclamo
     and cod_tipotran = '004'
	 and actualizado = 1

  let _pagos = 0;
	 
  select sum(monto)
    into _pagos
	from rectrcon
   where no_tranrec = _no_tranrec
     and cod_concepto in ('001','003','009','013','014','017','036');
	 
  if _pagos is null then
	let _pagos = 0;
  end if
	 
  let _pagos_tot = _pagos_tot + _pagos;  

end foreach

let _porc_perdida = (_pagos_tot + a_mano_obra + a_piezas ) / _perdida * 100;

end
if _porc_perdida > 65 then
	let _descripcion = 'POSIBLE PERDIDA';
else
	let _descripcion = '';
end if   
return _porc_perdida, _descripcion;
end procedure