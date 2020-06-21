
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';


(async() => {

    let result = null;

    let STATUS_CODES = [{
        // Label - unknown
        "label": "STATUS_CODE_UNKNOWN",
        "code": 0
    }, {
        // Label - on time
        "label": "STATUS_CODE_ON_TIME",
        "code": 10
    }, {
        // Label - airline late
        "label": "STATUS_CODE_LATE_AIRLINE",
        "code": 20
    }, {
        // Label - weather caused lateness
        "label": "STATUS_CODE_LATE_WEATHER",
        "code": 30
    }, {
        // Label - technical caused lateness
        "label": "STATUS_CODE_LATE_TECHNICAL",
        "code": 40
    }, {
        // Label - other reason for lateness (nonairline)
        "label": "STATUS_CODE_LATE_OTHER",
        "code": 50
    }];

    let contract = new Contract('localhost', () => {

        // Read transaction
        contract.isOperational((error, result) => {
            console.log(error,result);
            
            display('Operational Status', 'Check if contract is operational', [ { label: 'Operational Status', error: error, value: result} ]);
        });
    

        // User-submitted transaction
        DOM.elid('submit-oracle').addEventListener('click', () => {
            let flight = DOM.elid('flight-number').value;
            // Write transaction
            contract.fetchFlightStatus(flight, (error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        })
    
    });
    

})();

function displayList(flight, parentEl) {
    console.log(flight);
    console.log(parentEl);
    let el = document.createElement("option");
    el.text = `${flight.flight} - ${new Date((flight.timestamp))}`;
    el.value = JSON.stringify(flight);
    parentEl.add(el);
}

function display(title, description, results, customClass = null) {
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    section.appendChild(DOM.h2(title));
    section.appendChild(DOM.h5(description));
    results.map((result) => {
        let row = section.appendChild(DOM.div({className:'row'}));
        row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
        row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.value)));
        section.appendChild(row);
    })
    displayDiv.append(section);

}







