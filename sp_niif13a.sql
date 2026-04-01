-- Procedure de Generación del detalle Reclamos para IFRS XVII
-- Creado    : 01/12/2014 - Autor: Román Gordón
-- execute procedure sp_niif13a
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_niif13a;
create procedure sp_niif13a()
returning	integer			as error,
			integer			as error_isam,
			varchar(100)	as no_reclamo,
			varchar(100)	as error_desc,
			varchar(50)		as desc_clasif,
			varchar(50)		as categoria_contable,
			varchar(50)		as segm_triangulo;

define _error_desc			varchar(100);
define _desc_clasif			varchar(50);
define _categoria_contable	varchar(50);
define _segm_triangulo		varchar(50);
define _no_documento		char(20);
define _no_poliza			char(10);
define _no_reclamo			char(10);
define _cod_grupo			char(5);
define _no_unidad			char(5);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _cat1				char(2);
define _cat2				char(2);
define _cat3				char(2);
define _cat4				char(2);
define _cat5				char(2);
define _tipo_contrato		smallint;
define _no_cambio			smallint;
define _fronting			smallint;
define _cnt_cob				integer;
define _error				integer;
define _error_isam			integer;
define _porc_partic_prima	dec(9,6);
define _porc_facultativo	dec(9,6);
define _porc_retencion		dec(9,6);
define _porc_fronting		dec(9,6);
define _porc_cedido			dec(9,6);
define _porc_coas			dec(7,4);

set isolation to dirty read;


let _categoria_contable = '';
let _segm_triangulo = '';
let _desc_clasif = '';
let _cat5 = '04';

begin 
on exception set _error, _error_isam, _error_desc
	if _no_poliza is null then
		let _no_poliza = '';
	end if

	
	let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_no_documento) || trim(_error_desc);
	return _error,
		   _error_isam,
		   _error_desc,
		   '',
		   '',
		   '',
		   '';
end exception


--set debug file to "sp_niif013.trc";
--trace on;
foreach
	select no_poliza
	  into _no_poliza
	  from emipomae tmp
	 where no_poliza in ('2953456',
'2928795',
'2928811',
'2928812',
'2928831',
'2928841',
'2928886',
'2928887',
'2928888',
'2928935',
'2928953',
'2928960',
'2928970',
'2928974',
'2928975',
'2928985',
'2928996',
'2929046',
'2929073',
'2929088',
'2928943',
'2929601',
'2929667',
'2929923',
'2929925',
'2929927',
'2930080',
'2930099',
'2930125',
'2930157',
'2930174',
'2930189',
'2930194',
'2930199',
'2930207',
'2930223',
'2930231',
'2930232',
'2930237',
'2930241',
'2930245',
'2930262',
'2930264',
'2930266',
'2930270',
'2930369',
'2930390',
'2930453',
'2930469',
'2930479',
'2930494',
'2930498',
'2930515',
'2930516',
'2930530',
'2930580',
'2930606',
'2930618',
'2930645',
'2930706',
'2930737',
'2930839',
'2930914',
'2930944',
'2930947',
'2930949',
'2930953',
'2930985',
'2931039',
'2931055',
'2931090',
'2931141',
'2931161',
'2931207',
'2931210',
'2931261',
'2931273',
'2931291',
'2931322',
'2931333',
'2931395',
'2931428',
'2931465',
'2931542',
'2931583',
'2931592',
'2931618',
'2931630',
'2931637',
'2931702',
'2931743',
'2931765',
'2931833',
'2931841',
'2931916',
'2931934',
'2931944',
'2931961',
'2931984',
'2935214',
'2953488',
'2943298',
'2943307',
'2944039',
'2945196',
'2945302',
'2945310',
'2945813',
'2945847',
'2945871',
'2945725',
'2947900',
'2947938',
'2947945',
'2948050',
'2948069',
'2949635',
'2949737',
'2949868',
'2950953',
'2950995',
'2951017',
'2951387',
'2951832',
'2951935',
'2953620',
'2954154',
'2954157',
'2954204',
'2955597',
'2956376',
'2958495',
'2958620',
'2958908',
'2959252',
'2959386',
'2960062',
'2960082',
'2960680',
'2960685',
'2960715',
'2960899',
'2960916',
'2931444',
'2960923',
'2961822',
'2962524',
'2962619',
'2963235',
'2963944',
'2964021',
'2967799',
'2968864',
'2969028',
'2969079',
'2969605',
'2969613',
'2970101',
'2970205')

	call sp_niif13(_no_poliza,'','',1) 	
	returning _error,_error_isam,_error_desc,_desc_clasif,_categoria_contable,_segm_triangulo;
	
	return _error,
		   _error_isam,
		   _error_desc,
		   _no_poliza,
		   _desc_clasif,
		   _categoria_contable,
		   _segm_triangulo with resume;
end foreach
end
end procedure