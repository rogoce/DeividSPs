--- Renovacion Automatica. Proceso de excepciones
--- Creado 02/03/2009 por Armando Moreno

drop procedure sp_atc14;

create procedure "informix".sp_atc14(a_no_documento char (20))
returning integer;

define _reg 		integer;
define _no_poliza	char(10);
define _cod_ramo	char(3);
define _nueva_renov	char(1);


on exception in(-206)

	create temp table tmp_carta_decl( no_poliza		char(10),
									  no_documento	char(20),
									  cod_ramo		char(3),
									  nueva_renov	char(1)
									);

    create index i_tmp_carta_decl1 on tmp_carta_decl(no_documento);


	let _no_poliza = sp_sis21(a_no_documento);

	select nueva_renov,
		   cod_ramo
	  into _nueva_renov,
	  	   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	insert into tmp_carta_decl( no_poliza,
							    no_documento,
							    cod_ramo,
							    nueva_renov)
					    values( _no_poliza,
							    a_no_documento,
							    _cod_ramo,
							    _nueva_renov);

end exception

select count(*)
  into _reg
  from tmp_carta_decl;

let _no_poliza = sp_sis21(a_no_documento);

select nueva_renov,
	   cod_ramo
  into _nueva_renov,
  	   _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

insert into tmp_carta_decl( no_poliza,
						    no_documento,
						    cod_ramo,
						    nueva_renov)
				    values( _no_poliza,
						    a_no_documento,
						    _cod_ramo,
						    _nueva_renov);

return 0;
end procedure;
