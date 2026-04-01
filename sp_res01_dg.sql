--execute procedure sp_rec706('001','001','2014-06','2014-06',"*","*","002;","*","*")

drop procedure sp_res01_dg;
create procedure sp_res01_dg(a_compania char(3), a_agencia	char(3), a_periodo1	char(7), a_periodo2	char(7), a_sucursal	char(255) default "*", a_ramo char(255) default "*")
returning	char(18),date,varchar(100),decimal(16,2),char(10),char(1),char(50);

-- Reporte de Evolucion de las Reservas de Siniestros
-- Creado    : 08/04/2016 - Autor: Armando Moreno M.

define v_filtros			char(255);
define v_compania_nombre	char(50);
define v_ramo_nombre		char(50);
define _no_documento		char(20);
define v_doc_reclamo		char(18);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _no_unidad           char(5);
define _cod_sucursal		char(3);
define _cod_ramo			char(3);
define _tipo,_sexo				char(1);
define _reserva_bruto		dec(16,2);
define _pagado_bruto		dec(16,2);
define _cnt					smallint;
define _fecha_siniestro		date;
define _fecha_reclamo		date;
define _cod_evento          char(10);
define _n_evento,_n_sucursal varchar(50);
define _cod_subramo			char(3);
define _n_subramo			char(50);
define _pagado				dec(16,2);
define _reserva_bruto_f		dec(16,2);
define _pagado_bruto_f		dec(16,2);
define _cod_reclamante      char(10);
define _cod_icd             char(10);
define _n_reclamante        varchar(100);
define _cod_producto        char(5);
define _n_producto          char(50);


-- Nombre de la Compania
let  v_compania_nombre = sp_sis01(a_compania);

--BUSCAR RESERVA INICIAL
call sp_rec02(a_compania, a_agencia, a_periodo1,a_sucursal,'*','*',a_ramo,'*') returning v_filtros; 

--set debug file to "sp_rec706.trc"; 
--trace on; 
let _n_evento = '';

create temp table tmp_sinis1(
		no_reclamo			char(10)  not null,
		no_poliza			char(10)  not null,
		cod_sucursal		char(3)   not null,
		cod_grupo			char(5)   not null,
		cod_ramo			char(3)   not null,
		periodo				char(7)   not null,
		numrecla			char(18) ,
		ultima_fecha		date      not null,
		pagado_total		dec(16,2) not null,
		pagado_bruto		dec(16,2) not null,
		pagado_neto			dec(16,2) not null,
		reserva_total		dec(16,2) not null,
		reserva_bruto		dec(16,2) not null,
		reserva_neto		dec(16,2) not null,
		incurrido_total		dec(16,2) not null,
		incurrido_bruto		dec(16,2) not null,
		incurrido_neto		dec(16,2) not null,
  		ajust_interno		char(3),
		seleccionado		smallint  default 1 not null,
		porc_partic_coas	dec(16,4),
		no_documento        char(20),
		primary key (no_reclamo)) with no log;

create temp table tmp_sinis_sal(
		no_reclamo			char(10)  not null,
		no_poliza			char(10)  not null,
		cod_ramo			char(3)   not null,
		periodo				char(7)   not null,
		numrecla			char(18) ,
		cod_sucursal		char(3)   not null,
		pagado_bruto_f		dec(16,2) not null,
		reserva_bruto_f		dec(16,2) not null,
		pagado_bruto		dec(16,2) not null,
		reserva_bruto		dec(16,2) not null,
		seleccionado		smallint  default 1 not null,
		primary key (no_reclamo)) with no log;		


--CARGAR RESERVA INICIAL EN TABLA TEMPORAL
insert into tmp_sinis1
select * from tmp_sinis;

drop table tmp_sinis;

--BUSCAR RESERVA FINAL
call sp_rec02(a_compania, a_agencia, a_periodo2,a_sucursal,'*','*',a_ramo,'*') returning v_filtros;

let _reserva_bruto_f = 0;
let _pagado_bruto_f  = 0;
let _pagado          = 0;
--CARGANDO LA RESERVA FINAL EN TABLA TEMPORAL
foreach 
	select no_reclamo,		
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
		   cod_sucursal,
		   pagado_bruto,
		   reserva_bruto
	  into _no_reclamo,
		   _no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   _cod_sucursal,
		   _pagado_bruto,
		   _reserva_bruto
	  from tmp_sinis
     where seleccionado = 1
	   and no_poliza = '0001301129'
	 
	insert into tmp_sinis_sal(
	no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal,pagado_bruto_f,reserva_bruto_f,seleccionado,pagado_bruto,reserva_bruto)
	values(_no_reclamo,_no_poliza,_cod_ramo,_periodo,v_doc_reclamo,_cod_sucursal,_pagado_bruto,_reserva_bruto,1,0,0);
	
end foreach

--cargando la reserva inicial
foreach

	select no_reclamo,		
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
		   cod_sucursal,
		   pagado_bruto,
		   reserva_bruto
	  into _no_reclamo,
		   _no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   _cod_sucursal,
		   _pagado_bruto,
		   _reserva_bruto
	  from tmp_sinis1
	 where seleccionado = 1
	   and no_poliza = '0001301129'
	 
	select count(*)
	  into _cnt
	  from tmp_sinis_sal
	 where no_reclamo = _no_reclamo;
	  
	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt = 0 then
		insert into tmp_sinis_sal(
		no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal,pagado_bruto_f,reserva_bruto_f,seleccionado,pagado_bruto,reserva_bruto)
		values(_no_reclamo,_no_poliza,_cod_ramo,_periodo,v_doc_reclamo,_cod_sucursal,0,0,1,_pagado_bruto,_reserva_bruto);	
	else
		update tmp_sinis_sal
		   set reserva_bruto = _reserva_bruto,
		       pagado_bruto  = _pagado_bruto
		 where no_reclamo    = _no_reclamo; 
	end if	
	 
end foreach

foreach

	select no_reclamo,		
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
		   cod_sucursal,
		   sum(pagado_bruto),
		   sum(reserva_bruto),
		   sum(pagado_bruto_f),
		   sum(reserva_bruto_f)
	  into _no_reclamo,
		   _no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   _cod_sucursal,
		   _pagado_bruto,
		   _reserva_bruto,
		   _pagado_bruto_f,
		   _reserva_bruto_f
	  from tmp_sinis_sal
	 group by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal

	let _pagado = 0;
	
	--if _pagado_bruto_f > _pagado_bruto then
		let _pagado = _pagado_bruto_f - _pagado_bruto;
	--else
	--	let _pagado = _pagado_bruto - _pagado_bruto_f;
	--end if
	
	select no_unidad,
		   no_documento,
		   fecha_reclamo,
		   fecha_siniestro,
		   cod_evento,
		   periodo,
		   cod_sucursal,
		   cod_reclamante,
		   cod_icd
	  into _no_unidad,
	       _no_documento,
		   _fecha_reclamo,
		   _fecha_siniestro,
		   _cod_evento,
		   _periodo,
		   _cod_sucursal,
		   _cod_reclamante,
		   _cod_icd
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	select cod_producto
      into _cod_producto
      from emipouni
     where no_poliza = _no_poliza
       and no_unidad = _no_unidad;

	select nombre
	  into _n_producto
	  from prdprod
	 where cod_producto = _cod_producto; 
	 
	select nombre,
	       sexo
	  into _n_reclamante,
	       _sexo
 	  from cliclien
     where cod_cliente = _cod_reclamante;
	 
	select cod_subramo
      into _cod_subramo
      from emipomae
     where no_poliza = _no_poliza;
	 
	select nombre
	  into v_ramo_nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;
	 
	select nombre
      into _n_subramo
      from prdsubra
     where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;
	 
	 select nombre
	  into _n_evento
	  from recevent
	 where cod_evento = _cod_evento;

	select descripcion
	  into _n_sucursal
	  from insagen
	 where codigo_agencia  = _cod_sucursal
	   and codigo_compania = '001';

	return v_doc_reclamo,_fecha_reclamo,_n_reclamante,_reserva_bruto_f,_cod_icd,_sexo,_n_producto with resume;
		
end foreach
	
drop table tmp_sinis;
drop table tmp_sinis1;
drop table tmp_sinis_sal;

end procedure;	   