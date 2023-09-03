import React, { useState } from 'react';
import './App.css'
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";


// This will set the NUI to visible if we are
// developing in browser
debugData([
  {
    action: 'setVisible',
    data: true,
  }
])

interface ReturnClientDataCompProps {
  data: any
}

const ReturnClientDataComp: React.FC<ReturnClientDataCompProps> = ({ data }) => (
  <>
    <h5>Returned Data:</h5>
    <pre>
      <code>
        {JSON.stringify(data, null)}
      </code>
    </pre>
  </>
)

interface ReturnData {
  vehicleBrand: string;
  vehicleModel: string;
  vehiclePrice: number;
  vehicleHash: string;
  imageUrl: string;
}

function formatPriceWithCommas(price: number) {
  return price.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function handleImageError(event: React.SyntheticEvent<HTMLImageElement, Event>) {
  event.currentTarget.src = '/web/build/assets/import.png';
  event.currentTarget.onerror = null;
  event.currentTarget.classList.add('error');
}





const App: React.FC = () => {
  const [clientData, setClientData] = useState<ReturnData[] | null>(null);
  const [isContentVisible, setContentVisibility] = useState(true);

  const handleGetClientData = () => {
    fetchNui<ReturnData[]>('getClientData')
      .then((retData) => {
        const sortedData = retData.sort((a, b) => a.vehicleBrand.localeCompare(b.vehicleBrand));

        const dataWithImages = sortedData.map((vehicle) => ({
          ...vehicle,
          imageUrl: `https://docs.fivem.net/vehicles/${vehicle.vehicleHash}.webp`,
        }));

        setClientData(dataWithImages);
        setContentVisibility(false);
      })
      .catch((e) => {
        console.error('Setting mock data due to error', e);
        setClientData([{ vehicleBrand: '', vehicleModel: '', vehiclePrice: 0, vehicleHash: '', imageUrl: '' }]);
        setContentVisibility(false);
      });
  };


  return (
    <div className="nui-wrapper">
      <div className='popup-thing'>
        <div>
          {isContentVisible && (
            <>
              <h1>Browse Vehicle Catalogue</h1>
              <p>Exit with ESC</p>
            </>
          )}
          <button onClick={handleGetClientData}>Search</button>
          {clientData && (
            <div className="table-container-wrapper">
            <div className="table-container">
              <table>
                <thead>
                  <tr>
                    <th>Vehicle Make</th>
                    <th>Vehicle Model</th>
                    <th>Price</th>
                    <th>Image</th>
                  </tr>
                </thead>
                <tbody>
                  {clientData.map((vehicle, index) => (
                    <tr key={index}>
                      <td>{vehicle.vehicleBrand}</td>
                      <td>{vehicle.vehicleModel}</td>
                      <td>{formatPriceWithCommas(vehicle.vehiclePrice)}</td>
                      <td>
                        <div className="image-container">
                          <img src={vehicle.imageUrl || '/web/build/assets/import.png'} alt={vehicle.vehicleModel} onError={handleImageError} />
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;